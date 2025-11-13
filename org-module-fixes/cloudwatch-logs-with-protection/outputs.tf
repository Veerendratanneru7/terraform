output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.log_group.log_group_this_name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = "arn:aws:logs:*:*:log-group:${module.log_group.log_group_this_name}"
}
