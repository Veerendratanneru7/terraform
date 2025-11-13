output "portal_fqdn" {
  value = aws_route53_record.portal.fqdn
}

output "webapps_fqdn" {
  value = aws_route53_record.webapps.fqdn
}

output "callback_fqdn" {
  value = aws_route53_record.callback.fqdn
}

output "rds_fqdn" {
  value = aws_route53_record.rds.fqdn
}
