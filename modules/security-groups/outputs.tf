output "portal_alb_sg_id" {
  value = aws_security_group.portal_alb.id
}

output "portal_ec2_sg_id" {
  value = aws_security_group.portal_ec2.id
}

output "webapps_alb_sg_id" {
  value = aws_security_group.webapps_alb.id
}

output "webapps_ec2_sg_id" {
  value = aws_security_group.webapps_ec2.id
}

output "callback_alb_sg_id" {
  value = aws_security_group.callback_alb.id
}

output "callback_ec2_sg_id" {
  value = aws_security_group.callback_ec2.id
}
