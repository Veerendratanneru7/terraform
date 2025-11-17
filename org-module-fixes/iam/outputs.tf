output "role_arn" {
  value = aws_iam_role.mfa.arn
}

output "role_name" {
  value = aws_iam_role.mfa.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.mfa.name
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.mfa.arn
}

