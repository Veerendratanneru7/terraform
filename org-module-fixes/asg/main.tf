# User data can be passed directly or use template files from calling module
locals {
  user_data_final = var.user_data != null ? var.user_data : (
    var.user_data_template_file != null && var.user_data_template_vars != null ? 
    templatefile(var.user_data_template_file, var.user_data_template_vars) : 
    ""
  )
}

resource "aws_launch_template" "this" {
  name          = var.name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  vpc_security_group_ids = var.security_groups

  user_data = base64encode(local.user_data_final)

  dynamic "tag_specifications" {
    for_each = length(var.tag_specifications) > 0 ? var.tag_specifications : []
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "this" {
  name                      = var.name
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  default_cooldown          = var.default_cooldown

  launch_template {
    id      = aws_launch_template.this.id
    version = var.launch_template_version
  }

  enabled_metrics = var.enabled_metrics

  dynamic "tag" {
    for_each = var.asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = var.ignore_changes
  }

  timeouts {
    delete = var.timeout_delete
  }
}

# Optional: Target tracking scaling policy
resource "aws_autoscaling_policy" "target_tracking" {
  count = var.enable_target_tracking_scaling ? 1 : 0

  name                   = "${var.name}-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  dynamic "target_tracking_configuration" {
    for_each = var.target_tracking_configuration != null ? [var.target_tracking_configuration] : []
    content {
      predefined_metric_specification {
        predefined_metric_type = lookup(target_tracking_configuration.value, "predefined_metric_type", null)
      }

      dynamic "customized_metric_specification" {
        for_each = lookup(target_tracking_configuration.value, "customized_metric_specification", null) != null ? [target_tracking_configuration.value.customized_metric_specification] : []
        content {
          namespace   = customized_metric_specification.value.namespace
          metric_name = customized_metric_specification.value.metric_name
          statistic   = customized_metric_specification.value.statistic
          unit        = lookup(customized_metric_specification.value, "unit", null)

          dynamic "metric_dimension" {
            for_each = lookup(customized_metric_specification.value, "metric_dimensions", [])
            content {
              name  = metric_dimension.value.name
              value = metric_dimension.value.value
            }
          }
        }
      }

      target_value = target_tracking_configuration.value.target_value
    }
  }
}

# Optional: Scheduled scaling actions
resource "aws_autoscaling_schedule" "this" {
  for_each = var.autoscaling_schedules

  scheduled_action_name  = each.key
  autoscaling_group_name = aws_autoscaling_group.this.name
  min_size               = lookup(each.value, "min_size", null)
  max_size               = lookup(each.value, "max_size", null)
  desired_capacity       = lookup(each.value, "desired_capacity", null)
  recurrence             = lookup(each.value, "recurrence", null)
  start_time             = lookup(each.value, "start_time", null)
  end_time               = lookup(each.value, "end_time", null)
}

