import boto3
import os
import json

elbv2 = boto3.client('elbv2')
ssm = boto3.client('ssm')

LISTENER_ARN = os.environ['LISTENER_ARN']
BLUE_TG_ARN = os.environ['BLUE_TARGET_GROUP_ARN']
GREEN_TG_ARN = os.environ['GREEN_TARGET_GROUP_ARN']
SSM_ACTIVE_COLOR = os.environ.get('SSM_ACTIVE_COLOR_PARAM')
SSM_TRAFFIC_WEIGHT = os.environ.get('SSM_TRAFFIC_WEIGHT_PARAM')

def lambda_handler(event, context):
    """
    Gradually shift traffic between blue and green deployments
    """
    try:
        # Get current traffic weight from SSM or event
        current_weight = int(get_ssm_parameter(SSM_TRAFFIC_WEIGHT) or event.get('current_weight', 0))
        increment = event.get('increment', 10)
        target_weight = event.get('target_weight', 100)
        active_color = get_ssm_parameter(SSM_ACTIVE_COLOR) or event.get('active_color', 'blue')
        
        # Calculate new weight
        new_weight = min(current_weight + increment, target_weight)
        
        # Calculate weights for blue and green
        if active_color == 'blue':
            blue_weight = new_weight
            green_weight = 100 - new_weight
        else:
            green_weight = new_weight
            blue_weight = 100 - new_weight
        
        print(f"Shifting traffic: Blue={blue_weight}%, Green={green_weight}%")
        
        # Get listener rules
        rules = elbv2.describe_rules(ListenerArn=LISTENER_ARN)
        
        # Find the rule with forward action to both target groups
        for rule in rules['Rules']:
            for action in rule['Actions']:
                if action['Type'] == 'forward' and 'ForwardConfig' in action:
                    # Update the rule with new weights
                    elbv2.modify_rule(
                        RuleArn=rule['RuleArn'],
                        Actions=[{
                            'Type': 'forward',
                            'ForwardConfig': {
                                'TargetGroups': [
                                    {'TargetGroupArn': BLUE_TG_ARN, 'Weight': blue_weight},
                                    {'TargetGroupArn': GREEN_TG_ARN, 'Weight': green_weight}
                                ],
                                'TargetGroupStickinessConfig': {
                                    'Enabled': True,
                                    'DurationSeconds': 3600
                                }
                            }
                        }]
                    )
                    
                    # Update SSM parameter
                    if SSM_TRAFFIC_WEIGHT:
                        update_ssm_parameter(SSM_TRAFFIC_WEIGHT, str(new_weight))
                    
                    return {
                        'statusCode': 200,
                        'body': json.dumps({
                            'message': f'Traffic shifted successfully',
                            'blue_weight': blue_weight,
                            'green_weight': green_weight,
                            'new_weight': new_weight,
                            'complete': new_weight >= target_weight
                        })
                    }
        
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'No matching listener rule found'})
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def get_ssm_parameter(param_name):
    """Get SSM parameter value"""
    if not param_name:
        return None
    try:
        response = ssm.get_parameter(Name=param_name)
        return response['Parameter']['Value']
    except:
        return None

def update_ssm_parameter(param_name, value):
    """Update SSM parameter value"""
    try:
        ssm.put_parameter(
            Name=param_name,
            Value=value,
            Overwrite=True
        )
    except Exception as e:
        print(f"Failed to update SSM parameter: {e}")
