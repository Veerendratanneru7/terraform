output "portal_log_group_name" {
  value = aws_cloudwatch_log_group.portal.name
}

output "webapps_log_group_name" {
  value = aws_cloudwatch_log_group.webapps.name
}

output "callback_log_group_name" {
  value = aws_cloudwatch_log_group.callback.name
}

output "log_group_arns" {
  value = [
    aws_cloudwatch_log_group.portal.arn,
    aws_cloudwatch_log_group.webapps.arn,
    aws_cloudwatch_log_group.callback.arn
  ]
}
