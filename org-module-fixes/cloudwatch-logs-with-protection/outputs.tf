output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = local.log_group_name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.use_organizational_module ? module.log_group[0].log_group_this_arn : aws_cloudwatch_log_group.this[0].arn
}

output "log_group_id" {
  description = "ID of the CloudWatch log group"
  value       = local.log_group_name
}

output "data_protection_policy_arn" {
  description = "ARN of the data protection policy"
  value       = var.enable_data_protection ? aws_cloudwatch_log_data_protection_policy.this[0].log_group_name : null
}

