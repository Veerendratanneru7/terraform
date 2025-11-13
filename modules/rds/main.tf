resource "aws_db_parameter_group" "mfa" {
  name        = "smartvault-${var.env_id}-paramgrp-rds-mfa"
  family      = "mysql5.7"
  description = "Parameter group for MFA (aPersona) Server - support for case insensitive table names and default collation of UTF8"

  tags = {
    Name = "smartvault-${var.env_id}-paramgrp-rds-mfa"
  }
}

resource "aws_db_subnet_group" "mfa" {
  name        = "smartvault-${var.env_id}-subnetgrp-rds-mfa"
  description = "MFA DB Subnet Group"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "smartvault-${var.env_id}-subnetgrp-rds-mfa"
  }
}

resource "aws_db_instance" "mfa" {
  identifier              = "smartvault-${var.env_id}-rds-mfa"
  allocated_storage       = 22
  storage_type            = var.storage_type
  engine                  = "mysql"
  engine_version          = var.mysql_engine_version
  instance_class          = "db.t3.medium"
  db_name                 = "apersona"
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = aws_db_parameter_group.mfa.name
  db_subnet_group_name    = aws_db_subnet_group.mfa.name
  vpc_security_group_ids  = var.security_group_ids
  skip_final_snapshot     = false
  final_snapshot_identifier = "smartvault-${var.env_id}-rds-mfa-final-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name = "smartvault-${var.env_id}-rds-mfa"
  }

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

resource "aws_security_group_rule" "rds_from_webapps" {
  security_group_id        = var.security_group_ids[0]
  type                     = "ingress"
  description              = "Allow ASMWebapps MFA access"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.webapps_sg_id
}

resource "aws_security_group_rule" "rds_from_portal" {
  security_group_id        = var.security_group_ids[0]
  type                     = "ingress"
  description              = "Allow ASMPortal access"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.portal_sg_id
}
