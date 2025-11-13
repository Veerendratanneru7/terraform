resource "aws_route53_record" "portal" {
  zone_id = var.internal_zone_id
  name    = var.portal_hostname
  type    = "A"

  alias {
    name                   = var.portal_alb_dns
    zone_id                = var.portal_alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "webapps" {
  zone_id = var.internal_zone_id
  name    = var.webapps_hostname
  type    = "A"

  alias {
    name                   = var.webapps_alb_dns
    zone_id                = var.webapps_alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "callback" {
  zone_id = var.public_zone_id
  name    = var.callback_hostname
  type    = "A"

  alias {
    name                   = var.callback_alb_dns
    zone_id                = var.callback_alb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "rds" {
  zone_id = var.internal_zone_id
  name    = var.rds_hostname
  type    = "CNAME"
  ttl     = 900
  records = [var.rds_endpoint]
}
