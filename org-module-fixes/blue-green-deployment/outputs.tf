# ==============================================================================
# BLUE-GREEN DEPLOYMENT OUTPUTS
# ==============================================================================

output "active_deployment_color" {
  description = "Currently active deployment color"
  value       = var.active_deployment_color
}

output "blue_traffic_weight" {
  description = "Current traffic weight for blue deployment"
  value       = local.blue_weight
}

output "green_traffic_weight" {
  description = "Current traffic weight for green deployment"
  value       = local.green_weight
}

output "listener_rule_arn" {
  description = "ARN of the weighted listener rule"
  value       = var.enable_weighted_routing ? aws_lb_listener_rule.weighted[0].arn : null
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = var.enable_codedeploy ? aws_codedeploy_app.this[0].name : null
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = var.enable_codedeploy ? aws_codedeploy_deployment_group.this[0].deployment_group_name : null
}

output "deployment_state_parameter_name" {
  description = "SSM parameter name tracking active deployment color"
  value       = var.enable_deployment_tracking ? aws_ssm_parameter.deployment_state[0].name : null
}

output "traffic_weight_parameter_name" {
  description = "SSM parameter name tracking traffic weight"
  value       = var.enable_deployment_tracking ? aws_ssm_parameter.traffic_weight[0].name : null
}

output "traffic_shifter_lambda_arn" {
  description = "ARN of the traffic shifter Lambda function"
  value       = var.enable_automated_traffic_shift ? aws_lambda_function.traffic_shifter[0].arn : null
}

output "traffic_shift_schedule_name" {
  description = "Name of the EventBridge rule for traffic shifting"
  value       = var.enable_automated_traffic_shift && var.traffic_shift_schedule != null ? aws_cloudwatch_event_rule.traffic_shift_schedule[0].name : null
}
