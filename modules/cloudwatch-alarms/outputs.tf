output "alarm_arns" {
  value = [
    aws_cloudwatch_metric_alarm.portal_cpu.arn,
    aws_cloudwatch_metric_alarm.portal_disk.arn,
    aws_cloudwatch_metric_alarm.portal_memory.arn,
    aws_cloudwatch_metric_alarm.portal_status.arn,
    aws_cloudwatch_metric_alarm.webapps_cpu.arn,
    aws_cloudwatch_metric_alarm.webapps_memory_percent.arn,
    aws_cloudwatch_metric_alarm.webapps_disk.arn,
    aws_cloudwatch_metric_alarm.webapps_memory.arn,
    aws_cloudwatch_metric_alarm.callback_cpu.arn,
    aws_cloudwatch_metric_alarm.callback_disk.arn,
    aws_cloudwatch_metric_alarm.callback_memory.arn
  ]
}
