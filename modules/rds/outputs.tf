output "endpoint" {
  value       = aws_db_instance.mfa.endpoint
  description = "RDS instance endpoint"
}

output "address" {
  value       = aws_db_instance.mfa.address
  description = "RDS instance address"
}

output "arn" {
  value       = aws_db_instance.mfa.arn
  description = "RDS instance ARN"
}
