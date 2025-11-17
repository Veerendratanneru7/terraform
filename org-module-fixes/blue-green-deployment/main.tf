# ==============================================================================
# BLUE-GREEN DEPLOYMENT MODULE
# Manages blue-green deployment with automated traffic shifting
# ==============================================================================

locals {
  # Determine active and inactive environments
  active_color   = var.active_deployment_color
  inactive_color = var.active_deployment_color == "blue" ? "green" : "blue"
  
  # Traffic weight distribution
  blue_weight  = var.active_deployment_color == "blue" ? var.active_traffic_weight : (100 - var.active_traffic_weight)
  green_weight = var.active_deployment_color == "green" ? var.active_traffic_weight : (100 - var.active_traffic_weight)
}

# ==============================================================================
# LISTENER RULE WITH WEIGHTED TARGET GROUPS
# ==============================================================================

resource "aws_lb_listener_rule" "weighted" {
  count = var.enable_weighted_routing ? 1 : 0

  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type = "forward"
    
    forward {
      target_group {
        arn    = var.blue_target_group_arn
        weight = local.blue_weight
      }

      target_group {
        arn    = var.green_target_group_arn
        weight = local.green_weight
      }

      stickiness {
        enabled  = var.enable_stickiness
        duration = var.stickiness_duration
      }
    }
  }

  dynamic "condition" {
    for_each = var.host_header != null ? [1] : []
    content {
      host_header {
        values = [var.host_header]
      }
    }
  }

  dynamic "condition" {
    for_each = var.path_pattern != null ? [1] : []
    content {
      path_pattern {
        values = [var.path_pattern]
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# CODEDEPLOY APPLICATION
# ==============================================================================

resource "aws_codedeploy_app" "this" {
  count = var.enable_codedeploy ? 1 : 0

  name             = var.application_name
  compute_platform = "Server"

  tags = var.tags
}

# ==============================================================================
# CODEDEPLOY DEPLOYMENT GROUP
# ==============================================================================

resource "aws_codedeploy_deployment_group" "this" {
  count = var.enable_codedeploy ? 1 : 0

  app_name               = aws_codedeploy_app.this[0].name
  deployment_group_name  = "${var.application_name}-${var.component_name}"
  service_role_arn       = var.codedeploy_service_role_arn
  deployment_config_name = var.deployment_config_name

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  # Blue/Green deployment configuration
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = var.terminate_blue_instances_action
      termination_wait_time_in_minutes = var.blue_termination_wait_time
    }

    deployment_ready_option {
      action_on_timeout = var.deployment_ready_action
      wait_time_in_minutes = var.deployment_ready_wait_time
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }

  # Load balancer info
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }

      dynamic "test_traffic_route" {
        for_each = var.test_listener_arn != null ? [1] : []
        content {
          listener_arns = [var.test_listener_arn]
        }
      }

      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }

  # Trigger CloudWatch alarms for auto-rollback
  dynamic "alarm_configuration" {
    for_each = var.enable_alarm_rollback ? [1] : []
    content {
      enabled = true
      alarms  = var.rollback_alarm_names
    }
  }

  # Auto Scaling Groups
  dynamic "auto_scaling_groups" {
    for_each = var.autoscaling_group_names
    content {
      name = auto_scaling_groups.value
    }
  }

  tags = var.tags
}

# ==============================================================================
# DEPLOYMENT TRACKING (SSM Parameter for state)
# ==============================================================================

resource "aws_ssm_parameter" "deployment_state" {
  count = var.enable_deployment_tracking ? 1 : 0

  name        = "/deployment/${var.application_name}/${var.component_name}/active-color"
  description = "Tracks the currently active deployment color"
  type        = "String"
  value       = var.active_deployment_color

  tags = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "traffic_weight" {
  count = var.enable_deployment_tracking ? 1 : 0

  name        = "/deployment/${var.application_name}/${var.component_name}/traffic-weight"
  description = "Current traffic weight percentage for active deployment"
  type        = "String"
  value       = tostring(var.active_traffic_weight)

  tags = var.tags

  lifecycle {
    ignore_changes = [value]
  }
}

# ==============================================================================
# LAMBDA FOR AUTOMATED TRAFFIC SHIFTING (Optional)
# ==============================================================================

data "archive_file" "traffic_shifter" {
  count = var.enable_automated_traffic_shift ? 1 : 0

  type        = "zip"
  output_path = "${path.module}/lambda/traffic-shifter.zip"

  source {
    content  = templatefile("${path.module}/lambda/traffic-shifter.py.tpl", {
      listener_arn = var.listener_arn
      rule_arn     = var.enable_weighted_routing ? aws_lb_listener_rule.weighted[0].arn : ""
    })
    filename = "traffic-shifter.py"
  }
}

resource "aws_lambda_function" "traffic_shifter" {
  count = var.enable_automated_traffic_shift ? 1 : 0

  filename         = data.archive_file.traffic_shifter[0].output_path
  function_name    = "${var.application_name}-${var.component_name}-traffic-shifter"
  role            = var.lambda_execution_role_arn
  handler         = "traffic-shifter.lambda_handler"
  source_code_hash = data.archive_file.traffic_shifter[0].output_base64sha256
  runtime         = "python3.11"
  timeout         = 60

  environment {
    variables = {
      LISTENER_ARN           = var.listener_arn
      BLUE_TARGET_GROUP_ARN  = var.blue_target_group_arn
      GREEN_TARGET_GROUP_ARN = var.green_target_group_arn
      SSM_ACTIVE_COLOR_PARAM = var.enable_deployment_tracking ? aws_ssm_parameter.deployment_state[0].name : ""
      SSM_TRAFFIC_WEIGHT_PARAM = var.enable_deployment_tracking ? aws_ssm_parameter.traffic_weight[0].name : ""
    }
  }

  tags = var.tags
}

# EventBridge rule for scheduled traffic shifting
resource "aws_cloudwatch_event_rule" "traffic_shift_schedule" {
  count = var.enable_automated_traffic_shift && var.traffic_shift_schedule != null ? 1 : 0

  name                = "${var.application_name}-${var.component_name}-traffic-shift"
  description         = "Triggers gradual traffic shift for blue-green deployment"
  schedule_expression = var.traffic_shift_schedule

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "traffic_shifter" {
  count = var.enable_automated_traffic_shift && var.traffic_shift_schedule != null ? 1 : 0

  rule      = aws_cloudwatch_event_rule.traffic_shift_schedule[0].name
  target_id = "TrafficShifter"
  arn       = aws_lambda_function.traffic_shifter[0].arn

  input = jsonencode({
    increment     = var.traffic_shift_increment
    target_weight = 100
  })
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count = var.enable_automated_traffic_shift && var.traffic_shift_schedule != null ? 1 : 0

  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.traffic_shifter[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.traffic_shift_schedule[0].arn
}
