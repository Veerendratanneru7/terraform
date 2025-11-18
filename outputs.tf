output "portal_asg_name" {
  value       = module.asg_portal.asg_name
  description = "Portal Auto Scaling Group name"
}

output "webapps_asg_name" {
  value       = module.asg_webapps.asg_name
  description = "WebApps Auto Scaling Group name"
}

output "callback_asg_name" {
  value       = module.asg_callback.asg_name
  description = "Callback Auto Scaling Group name"
}

output "portal_alb_dns" {
  value       = module.alb_portal.alb_dns_name
  description = "Portal ALB DNS name"
}

output "webapps_alb_dns" {
  value       = module.alb_webapps.alb_dns_name
  description = "WebApps ALB DNS name"
}

output "callback_alb_dns" {
  value       = module.alb_callback.alb_dns_name
  description = "Callback ALB DNS name"
}

output "rds_endpoint" {
  value       = module.rds.endpoint
  description = "RDS endpoint"
  sensitive   = true
}

output "rds_hostname" {
  value       = module.route53.rds_fqdn
  description = "RDS Route53 hostname"
}

output "deployment_color" {
  value       = var.deployment_color
  description = "Current deployment color"
}

# ==============================================================================
# IAM OUTPUTS
# ==============================================================================

output "iam_role_arn" {
  value       = aws_iam_role.mfa.arn
  description = "IAM role ARN for MFA instances"
}

output "iam_role_name" {
  value       = aws_iam_role.mfa.name
  description = "IAM role name for MFA instances"
}

output "iam_instance_profile_name" {
  value       = aws_iam_instance_profile.mfa.name
  description = "IAM instance profile name for MFA instances"
}

output "iam_instance_profile_arn" {
  value       = aws_iam_instance_profile.mfa.arn
  description = "IAM instance profile ARN for MFA instances"
}
