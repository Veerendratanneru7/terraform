resource "aws_cloudwatch_metric_alarm" "portal_cpu" {
  alarm_name          = "smartvault-${var.env_id}-ASMPortal-HighCPU"
  alarm_description   = "High CPU usage alarm for ASMPortal in ${var.env_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  actions_enabled     = var.alarms_enabled

  dimensions = {
    AutoScalingGroupName = var.portal_asg_name
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "portal_disk" {
  alarm_name          = "smartvault-${var.env_id}-ASMPortal-LowFreeSpace"
  alarm_description   = "Low disk space alarm for ASMPortal in ${var.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 1000
  actions_enabled     = var.alarms_enabled

  metric_query {
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "DiskFree(/)-MB"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "DiskFree - /"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions = {
        AutoScalingGroupName = var.portal_asg_name
      }
    }
    return_data = false
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "portal_memory" {
  alarm_name          = "smartvault-${var.env_id}-ASMPortal-LowAvailableMemory"
  alarm_description   = "Low available memory alarm for ASMPortal in ${var.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 512
  actions_enabled     = var.alarms_enabled

  metric_query {
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "MemAvailable-MB"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "MemAvailable"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions = {
        AutoScalingGroupName = var.portal_asg_name
      }
    }
    return_data = false
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "portal_status" {
  alarm_name          = "${var.portal_asg_name}: ASM Portal Status"
  alarm_description   = "${var.portal_asg_name}: ASM Portal Status"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "ASMPortalStatus"
  namespace           = "System/Linux"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  actions_enabled     = var.alarms_enabled

  dimensions = {
    AutoScalingGroupName = var.portal_asg_name
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "webapps_cpu" {
  alarm_name          = "smartvault-${var.env_id}-ASMWebApps-HighCPU"
  alarm_description   = "High CPU usage alarm for ASMWebApps in ${var.env_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  actions_enabled     = var.alarms_enabled

  dimensions = {
    AutoScalingGroupName = var.webapps_asg_name
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "webapps_memory_percent" {
  alarm_name          = "smartvault-${var.env_id}-ASMWebApps-Memutilizationpercent"
  alarm_description   = "Memory utilization percentage alarm for ASMWebApps in ${var.env_id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  actions_enabled     = var.alarms_enabled

  dimensions = {
    AutoScalingGroupName = var.webapps_asg_name
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "webapps_disk" {
  alarm_name          = "smartvault-${var.env_id}-ASMWebApps-LowFreeSpace"
  alarm_description   = "Low disk space alarm for ASMWebApps in ${var.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 1000
  actions_enabled     = var.alarms_enabled

  metric_query {
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "DiskFree(/)-MB"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "DiskFree - /"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions = {
        AutoScalingGroupName = var.webapps_asg_name
      }
    }
    return_data = false
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "webapps_memory" {
  alarm_name          = "smartvault-${var.env_id}-ASMWebApps-LowAvailableMemory"
  alarm_description   = "Low available memory alarm for ASMWebApps in ${var.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 512
  actions_enabled     = var.alarms_enabled

  metric_query {
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "MemAvailable-MB"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "MemAvailable"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions = {
        AutoScalingGroupName = var.webapps_asg_name
      }
    }
    return_data = false
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "callback_cpu" {
  alarm_name          = "smartvault-${var.env_id}-ASMCallback-HighCPU"
  alarm_description   = "High CPU usage alarm for ASMCallback in ${var.env_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  actions_enabled     = var.alarms_enabled

  dimensions = {
    AutoScalingGroupName = var.callback_asg_name
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "callback_disk" {
  alarm_name          = "smartvault-${var.env_id}-ASMCallback-LowFreeSpace"
  alarm_description   = "Low disk space alarm for ASMCallback in ${var.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 1000
  actions_enabled     = var.alarms_enabled

  metric_query {
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "DiskFree(/)-MB"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "DiskFree - /"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions = {
        AutoScalingGroupName = var.callback_asg_name
      }
    }
    return_data = false
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "callback_memory" {
  alarm_name          = "smartvault-${var.env_id}-ASMCallback-LowAvailableMemory"
  alarm_description   = "Low available memory alarm for ASMCallback in ${var.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 512
  actions_enabled     = var.alarms_enabled

  metric_query {
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "MemAvailable-MB"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "MemAvailable"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions = {
        AutoScalingGroupName = var.callback_asg_name
      }
    }
    return_data = false
  }

  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = [var.sns_topic_arn]
  insufficient_data_actions = [var.sns_topic_arn]
}
