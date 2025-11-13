resource "aws_security_group" "webapps_alb" {
  name        = "smartvault-${var.env_id}-secgrp-ASMWebapps-mfa"
  description = "Security group for ASMWebapps with specific inbound and outbound rules"
  vpc_id      = var.vpc_id

  tags = {
    Name = "smartvault-${var.env_id}-secgrp-ASMWebapps-mfa"
  }
}

resource "aws_vpc_security_group_ingress_rule" "webapps_alb_from_webserver" {
  security_group_id            = aws_security_group.webapps_alb.id
  description                  = "Webserver-MFA access"
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.ec2_webserver_sg_id
}

resource "aws_vpc_security_group_egress_rule" "webapps_alb" {
  security_group_id = aws_security_group.webapps_alb.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "webapps_ec2" {
  name        = "smartvault-${var.env_id}-secgrp-ASMWebapps-mfa-ec2"
  description = "Security group for ASMWebapps EC2 instance allowing SSH and Webapps Load Balancer access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "smartvault-${var.env_id}-secgrp-ASMWebapps-mfa-ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "webapps_ec2_ssh" {
  security_group_id            = aws_security_group.webapps_ec2.id
  description                  = "Remote Admin - SSH access"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.remoteadmin_sg_id
}

resource "aws_vpc_security_group_ingress_rule" "webapps_ec2_from_alb" {
  security_group_id            = aws_security_group.webapps_ec2.id
  description                  = "MFA access"
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.webapps_alb.id
}

resource "aws_vpc_security_group_egress_rule" "webapps_ec2" {
  security_group_id = aws_security_group.webapps_ec2.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "callback_alb" {
  name        = "smartvault-${var.env_id}-secgrp-ASMCallback-mfa"
  description = "Security group for ASMCallback Load Balancer allowing inbound HTTP/HTTPS traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "smartvault-${var.env_id}-secgrp-ASMCallback-mfa"
  }
}

resource "aws_vpc_security_group_ingress_rule" "callback_alb_http" {
  security_group_id = aws_security_group.callback_alb.id
  description       = "Allow inbound HTTP traffic"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "callback_alb_https" {
  security_group_id = aws_security_group.callback_alb.id
  description       = "Allow inbound HTTPS traffic"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "callback_alb" {
  security_group_id = aws_security_group.callback_alb.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "callback_ec2" {
  name        = "smartvault-${var.env_id}-secgrp-ASMCallback-mfa-ec2"
  description = "Security group for ASMCallback EC2 instance allowing SSH and Web Access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "smartvault-${var.env_id}-secgrp-ASMCallback-mfa-ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "callback_ec2_ssh" {
  security_group_id            = aws_security_group.callback_ec2.id
  description                  = "Remote Admin - SSH access"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.remoteadmin_sg_id
}

resource "aws_vpc_security_group_ingress_rule" "callback_ec2_from_alb" {
  security_group_id            = aws_security_group.callback_ec2.id
  description                  = "Allow HTTP traffic"
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.callback_alb.id
}

resource "aws_vpc_security_group_egress_rule" "callback_ec2" {
  security_group_id = aws_security_group.callback_ec2.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "portal_alb" {
  name        = "smartvault-${var.env_id}-secgrp-ASMPortal-mfa"
  description = "Security group for ASMPortal Load Balancer allowing inbound HTTP/HTTPS traffic for Portal access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "smartvault-${var.env_id}-secgrp-ASMPortal-mfa"
  }
}

resource "aws_vpc_security_group_ingress_rule" "portal_alb_http" {
  security_group_id            = aws_security_group.portal_alb.id
  description                  = "Allow HTTP traffic"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.remoteadmin_sg_id
}

resource "aws_vpc_security_group_ingress_rule" "portal_alb_https" {
  security_group_id            = aws_security_group.portal_alb.id
  description                  = "Allow HTTPS traffic"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.remoteadmin_sg_id
}

resource "aws_vpc_security_group_egress_rule" "portal_alb" {
  security_group_id = aws_security_group.portal_alb.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "portal_ec2" {
  name        = "smartvault-${var.env_id}-secgrp-ASMPortal-mfa-ec2"
  description = "Security group for ASMPortal EC2 instance allowing SSH and OpenVPN access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "smartvault-${var.env_id}-secgrp-ASMPortal-mfa-ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "portal_ec2_ssh" {
  security_group_id            = aws_security_group.portal_ec2.id
  description                  = "Remote Admin - SSH access"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.remoteadmin_sg_id
}

resource "aws_vpc_security_group_ingress_rule" "portal_ec2_from_alb" {
  security_group_id            = aws_security_group.portal_ec2.id
  description                  = "Remote Admin - OpenVPN access"
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.portal_alb.id
}

resource "aws_vpc_security_group_egress_rule" "portal_ec2" {
  security_group_id = aws_security_group.portal_ec2.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
