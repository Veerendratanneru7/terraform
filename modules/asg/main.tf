locals {
  user_data_portal = templatefile("${path.module}/user-data/portal.sh.tpl", {
    env_id            = var.env_id
    mfa_version       = var.mfa_version
    db_password       = var.db_password
    rds_endpoint      = var.rds_endpoint
    secret_key_twilio = var.secret_key_twilio
    callback_url      = var.callback_url
    jvm_xms           = var.jvm_xms
    jvm_xmx           = var.jvm_xmx
    aws_region        = var.aws_region
    asg_name          = var.name
  })

  user_data_webapps = templatefile("${path.module}/user-data/webapps.sh.tpl", {
    env_id            = var.env_id
    mfa_version       = var.mfa_version
    db_password       = var.db_password
    rds_endpoint      = var.rds_endpoint
    secret_key_twilio = var.secret_key_twilio
    callback_url      = var.callback_url
    upgrade_db        = var.upgrade_db
    jvm_xms           = var.jvm_xms
    jvm_xmx           = var.jvm_xmx
    aws_region        = var.aws_region
    asg_name          = var.name
  })

  user_data_callback = templatefile("${path.module}/user-data/callback.sh.tpl", {
    secret_key_twilio = var.secret_key_twilio
    jvm_xms           = var.jvm_xms
    jvm_xmx           = var.jvm_xmx
    aws_region        = var.aws_region
    asg_name          = var.name
  })

  user_data = var.component == "portal" ? local.user_data_portal : (var.component == "webapps" ? local.user_data_webapps : local.user_data_callback)
}

resource "aws_launch_template" "main" {
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

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = var.name
      Component = var.component
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name                = var.name
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "EC2"
  health_check_grace_period = 300
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  default_cooldown    = 300

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupInServiceInstances"
  ]

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "Component"
    value               = var.component
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "memory_target_tracking" {
  count = var.enable_memory_scaling ? 1 : 0

  name                   = "${var.name}-memory-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    customized_metric_specification {
      namespace   = "System/Linux"
      metric_name = "MemoryUtilization"
      statistic   = "Average"
      unit        = "Percent"

      metric_dimension {
        name  = "AutoScalingGroupName"
        value = aws_autoscaling_group.main.name
      }
    }

    target_value = 80.0
  }
}

resource "aws_autoscaling_schedule" "scale_up" {
  count = var.schedule_enabled ? 1 : 0

  scheduled_action_name  = "${var.name}-scale-up"
  autoscaling_group_name = aws_autoscaling_group.main.name
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  recurrence             = var.schedule_up
}

resource "aws_autoscaling_schedule" "scale_down" {
  count = var.schedule_enabled ? 1 : 0

  scheduled_action_name  = "${var.name}-scale-down"
  autoscaling_group_name = aws_autoscaling_group.main.name
  min_size               = 0
  max_size               = 2
  desired_capacity       = 0
  recurrence             = var.schedule_down
}
