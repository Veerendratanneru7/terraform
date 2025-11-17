# Reusable CloudWatch Metric Alarm
resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.alarm_name
  alarm_description   = var.alarm_description
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  threshold           = var.threshold
  actions_enabled     = var.actions_enabled
  treat_missing_data  = var.treat_missing_data

  # Simple metric configuration
  metric_name = var.metric_name
  namespace   = var.namespace
  period      = var.period
  statistic   = var.statistic
  unit        = var.unit
  dimensions  = var.dimensions

  # Metric queries for complex metrics (disk, memory with expressions)
  dynamic "metric_query" {
    for_each = var.metric_queries
    content {
      id          = metric_query.value.id
      expression  = lookup(metric_query.value, "expression", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", null) != null ? [metric_query.value.metric] : []
        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", {})
        }
      }
    }
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}
