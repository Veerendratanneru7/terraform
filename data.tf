data "aws_caller_identity" "current" {}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${var.aws_region}-vpc"]
  }
}

data "aws_subnets" "private_app" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Type = "PrivateApp"
  }
}

data "aws_subnet" "private_app_1" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${var.aws_region}-subnet-privateapp1"]
  }
}

data "aws_subnet" "private_app_2" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${var.aws_region}-subnet-privateapp2"]
  }
}

data "aws_subnets" "private_data" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Type = "PrivateData"
  }
}

data "aws_subnet" "private_data_1" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${var.aws_region}-subnet-privatedata1"]
  }
}

data "aws_subnet" "private_data_2" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${var.aws_region}-subnet-privatedata2"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Type = "Public"
  }
}

data "aws_subnet" "public_1" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${var.aws_region}-subnet-public1"]
  }
}

data "aws_subnet" "public_2" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${var.aws_region}-subnet-public2"]
  }
}

data "aws_security_group" "remoteadmin" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-secgrp-remoteadmin"]
  }
}

data "aws_security_group" "ec2_webserver" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${local.env_id}-secgrp-ec2-webserver"]
  }
}

data "aws_security_group" "rds_mfa" {
  filter {
    name   = "tag:Name"
    values = ["smartvault-${local.env_id}-secgrp-rds-mfa"]
  }
}

data "aws_sns_topic" "alerts" {
  name = "smartvault-${local.env_id}-sns-topic-alerts"
}

data "aws_route53_zone" "internal" {
  name         = "int.${local.domain}"
  private_zone = false
}

data "aws_route53_zone" "public" {
  name         = local.domain
  private_zone = false
}

data "aws_acm_certificate" "wildcard" {
  domain   = "*.${local.domain}"
  statuses = ["ISSUED"]
}

data "aws_iam_group" "devops" {
  count      = local.is_production ? 1 : 0
  group_name = "smartvault-iam-group-devops"
}

data "aws_ssm_parameter" "db_upgrade_status" {
  name = "/${local.env_id}/apersona/dbupgrade"

  lifecycle {
    postcondition {
      condition     = !var.upgrade_db || self.value != "True"
      error_message = "Database upgrade has already been performed"
    }
  }
}
