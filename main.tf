# ==============================================================================
# SMARTVAULT MFA INFRASTRUCTURE
# Refactored to use organizational modules from sv-modules/ directory
# Custom modules in org-module-fixes/ for missing functionality
# ==============================================================================

# ==============================================================================
# CLOUDWATCH LOG GROUPS - Using Org Module with Data Protection Wrapper
# ==============================================================================

module "cloudwatch_log_portal" {
  source = "./org-module-fixes/cloudwatch-logs-with-protection"

  log_group_name         = "/aws/ec2/${local.env_id}/mfa/portal"
  retention_in_days      = 30
  enable_data_protection = true
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-loggroup-portal-mfa"
    Component = "Portal"
  })
}

module "cloudwatch_log_webapps" {
  source = "./org-module-fixes/cloudwatch-logs-with-protection"

  log_group_name         = "/aws/ec2/${local.env_id}/mfa/webapps"
  retention_in_days      = 30
  enable_data_protection = true
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-loggroup-webapps-mfa"
    Component = "WebApps"
  })
}

module "cloudwatch_log_callback" {
  source = "./org-module-fixes/cloudwatch-logs-with-protection"

  log_group_name         = "/aws/ec2/${local.env_id}/mfa/callback"
  retention_in_days      = 30
  enable_data_protection = true
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-loggroup-callback-mfa"
    Component = "Callback"
  })
}

# ==============================================================================
# IAM - Using org-module-fixes (No org module available)
# ==============================================================================

module "iam" {
  source = "./org-module-fixes/iam"

  env_id           = local.env_id
  account_id       = local.account_id
  is_production    = local.is_production
  restricted_users = var.restricted_users
  log_group_arns = [
    module.cloudwatch_log_portal.log_group_arn,
    module.cloudwatch_log_webapps.log_group_arn,
    module.cloudwatch_log_callback.log_group_arn
  ]
}

# ==============================================================================
# SECURITY GROUPS - Using Org Modules
# ==============================================================================

# Portal ALB Security Group
module "sg_portal_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group"

  name        = "smartvault-${local.env_id}-secgrp-ASMPortal-mfa"
  description = "Security group for ASM Portal Application Load Balancer"
  vpc_id      = data.aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-secgrp-ASMPortal-mfa"
    Component = "Portal-ALB"
  })
}

module "sg_rules_portal_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-cidr"

  security_group_id = module.sg_portal_alb.security_group_id

  rules = {
    ingress_8080 = {
      type        = "ingress"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "Allow inbound traffic on port 8080 from internal network"
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
}

# Portal EC2 Security Group
module "sg_portal_ec2" {
  source = "./sv-modules/smartvault-terraform-aws-security-group"

  name        = "smartvault-${local.env_id}-secgrp-ASMPortal-mfa-ec2"
  description = "Security group for ASM Portal EC2 instances"
  vpc_id      = data.aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-secgrp-ASMPortal-mfa-ec2"
    Component = "Portal-EC2"
  })
}

module "sg_rule_portal_ec2_from_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-source-sg"

  type                     = "ingress"
  description              = "Allow traffic from Portal ALB on port 8080"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.sg_portal_ec2.security_group_id
  source_security_group_id = module.sg_portal_alb.security_group_id
}

module "sg_rule_portal_ec2_ssh" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-source-sg"

  type                     = "ingress"
  description              = "Allow SSH from remote admin"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.sg_portal_ec2.security_group_id
  source_security_group_id = data.aws_security_group.remoteadmin.id
}

module "sg_rules_portal_ec2_egress" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-cidr"

  security_group_id = module.sg_portal_ec2.security_group_id

  rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
}

# WebApps ALB Security Group
module "sg_webapps_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group"

  name        = "smartvault-${local.env_id}-secgrp-ASMWebapps-mfa"
  description = "Security group for ASM WebApps Application Load Balancer"
  vpc_id      = data.aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-secgrp-ASMWebapps-mfa"
    Component = "WebApps-ALB"
  })
}

module "sg_rules_webapps_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-cidr"

  security_group_id = module.sg_webapps_alb.security_group_id

  rules = {
    ingress_8080 = {
      type        = "ingress"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "Allow inbound traffic on port 8080 from internal network"
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
}

# WebApps EC2 Security Group
module "sg_webapps_ec2" {
  source = "./sv-modules/smartvault-terraform-aws-security-group"

  name        = "smartvault-${local.env_id}-secgrp-ASMWebapps-mfa-ec2"
  description = "Security group for ASM WebApps EC2 instances"
  vpc_id      = data.aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-secgrp-ASMWebapps-mfa-ec2"
    Component = "WebApps-EC2"
  })
}

module "sg_rule_webapps_ec2_from_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-source-sg"

  type                     = "ingress"
  description              = "Allow traffic from WebApps ALB on port 8080"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.sg_webapps_ec2.security_group_id
  source_security_group_id = module.sg_webapps_alb.security_group_id
}

module "sg_rule_webapps_ec2_ssh" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-source-sg"

  type                     = "ingress"
  description              = "Allow SSH from remote admin"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.sg_webapps_ec2.security_group_id
  source_security_group_id = data.aws_security_group.remoteadmin.id
}

module "sg_rules_webapps_ec2_egress" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-cidr"

  security_group_id = module.sg_webapps_ec2.security_group_id

  rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
}

# Callback ALB Security Group
module "sg_callback_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group"

  name        = "smartvault-${local.env_id}-secgrp-ASMCallback-mfa"
  description = "Security group for ASM Callback Application Load Balancer"
  vpc_id      = data.aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-secgrp-ASMCallback-mfa"
    Component = "Callback-ALB"
  })
}

module "sg_rules_callback_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-cidr"

  security_group_id = module.sg_callback_alb.security_group_id

  rules = {
    ingress_80 = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from internet"
    }
    ingress_443 = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from internet"
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
}

# Callback EC2 Security Group
module "sg_callback_ec2" {
  source = "./sv-modules/smartvault-terraform-aws-security-group"

  name        = "smartvault-${local.env_id}-secgrp-ASMCallback-mfa-ec2"
  description = "Security group for ASM Callback EC2 instances"
  vpc_id      = data.aws_vpc.main.id
  
  tags = merge(local.common_tags, {
    Name      = "smartvault-${local.env_id}-secgrp-ASMCallback-mfa-ec2"
    Component = "Callback-EC2"
  })
}

module "sg_rule_callback_ec2_from_alb" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-source-sg"

  type                     = "ingress"
  description              = "Allow traffic from Callback ALB on port 8080"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.sg_callback_ec2.security_group_id
  source_security_group_id = module.sg_callback_alb.security_group_id
}

module "sg_rule_callback_ec2_ssh" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-source-sg"

  type                     = "ingress"
  description              = "Allow SSH from remote admin"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.sg_callback_ec2.security_group_id
  source_security_group_id = data.aws_security_group.remoteadmin.id
}

module "sg_rules_callback_ec2_egress" {
  source = "./sv-modules/smartvault-terraform-aws-security-group-rule-cidr"

  security_group_id = module.sg_callback_ec2.security_group_id

  rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }
}

# ==============================================================================
# RDS - Using Org Module
# ==============================================================================

module "rds" {
  source = "./sv-modules/smartvault-terraform-aws-rds"

  identifier     = "smartvault-${local.env_id}-rds-mfa"
  engine         = "mysql"
  engine_version = var.mysql_engine_version
  instance_class = "db.t3.medium"

  allocated_storage = 50
  storage_type      = var.rds_storage_type
  storage_encrypted = true

  db_name  = "mfa"
  username = var.db_username
  password = var.db_password
  port     = 3306

  multi_az                = false
  db_subnet_group_name    = "smartvault-${local.env_id}-subnetgrp-rds-mfa"
  vpc_security_group_ids  = [data.aws_security_group.rds_mfa.id]

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot                 = false
  final_snapshot_identifier_prefix    = "smartvault-${local.env_id}-rds-mfa"

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  create_db_parameter_group = true
  parameter_group_name      = "smartvault-${local.env_id}-paramgrp-rds-mfa"
  family                    = "mysql5.7"

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-rds-mfa"
  })
}

# ==============================================================================
# LOAD BALANCERS - Using Org Modules
# ==============================================================================

module "alb_portal" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer"

  name_prefix                      = "svportal"
  load_balancer_type               = "application"
  internal                         = true
  subnets                          = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  security_group                   = [module.sg_portal_alb.security_group_id]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false
  idle_timeout                     = 60

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-intalb-portal-mfa${local.blue_green_suffix}"
  })
}

module "alb_webapps" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer"

  name_prefix                      = "svwebapp"
  load_balancer_type               = "application"
  internal                         = true
  subnets                          = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  security_group                   = [module.sg_webapps_alb.security_group_id]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false
  idle_timeout                     = 60

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-intalb-webapp-mfa${local.blue_green_suffix}"
  })
}

module "alb_callback" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer"

  name_prefix                      = "svcallback"
  load_balancer_type               = "application"
  internal                         = false
  subnets                          = [data.aws_subnet.public_1.id, data.aws_subnet.public_2.id]
  security_group                   = [module.sg_callback_alb.security_group_id]
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = false
  idle_timeout                     = 60

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-alb-callback-mfa${local.blue_green_suffix}"
  })
}

# ==============================================================================
# TARGET GROUPS - Using Org Module
# ==============================================================================

module "tg_portal" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-target-group"

  name        = "sv-${local.env_id}-portal${local.blue_green_suffix}"
  vpc         = data.aws_vpc.main.id
  port        = "8080"
  protocol    = "HTTP"
  target_type = "instance"

  deregistration_delay = local.alb_deregistration_delay

  health_check_port     = "8080"
  health_check_protocol = "HTTP"
  health_check_path     = "/asm_portal/login.ap"
  health_check_interval = 30
  health_check_timeout  = 5
  health_check_matcher  = 200

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-tg-portal-mfa${local.blue_green_suffix}"
  })
}

module "tg_webapps" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-target-group"

  name        = "sv-${local.env_id}-webapps${local.blue_green_suffix}"
  vpc         = data.aws_vpc.main.id
  port        = "8080"
  protocol    = "HTTP"
  target_type = "instance"

  deregistration_delay = local.alb_deregistration_delay

  health_check_port     = "8080"
  health_check_protocol = "HTTP"
  health_check_path     = "/health/index.html"
  health_check_interval = 30
  health_check_timeout  = 5
  health_check_matcher  = 200

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-tg-webapps-mfa${local.blue_green_suffix}"
  })
}

module "tg_callback" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-target-group"

  name        = "sv-${local.env_id}-callback${local.blue_green_suffix}"
  vpc         = data.aws_vpc.main.id
  port        = "8080"
  protocol    = "HTTP"
  target_type = "instance"

  deregistration_delay = local.alb_deregistration_delay

  health_check_port     = "8080"
  health_check_protocol = "HTTP"
  health_check_path     = "/health/index.html"
  health_check_interval = 30
  health_check_timeout  = 5
  health_check_matcher  = 200

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-tg-callback-mfa${local.blue_green_suffix}"
  })
}

# ==============================================================================
# ALB LISTENERS - Using Org Module
# Note: Listener rules needed to connect listeners to target groups
# ==============================================================================

module "listener_portal" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener"

  lb_arn          = module.alb_portal.arn
  port            = 8080
  protocol        = "HTTPS"
  ssl_policy      = var.ssl_policy
  certificate_arn = local.certificate_arn

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-listener-portal-https"
  })
}

module "listener_rule_portal" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener-rule"

  listener_arn      = module.listener_portal.listener_arn
  target_group_arn  = module.tg_portal.arn
  host_header       = local.portal_hostname
  priority          = "1"
}

module "listener_webapps" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener"

  lb_arn   = module.alb_webapps.arn
  port     = 8080
  protocol = "HTTP"

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-listener-webapps-http"
  })
}

module "listener_rule_webapps" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener-rule"

  listener_arn      = module.listener_webapps.listener_arn
  target_group_arn  = module.tg_webapps.arn
  host_header       = local.webapps_hostname
  priority          = "1"
}

module "listener_callback_http" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener"

  lb_arn   = module.alb_callback.arn
  port     = 80
  protocol = "HTTP"

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-listener-callback-http"
  })
}

module "listener_rule_callback_http" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener-rule"

  listener_arn      = module.listener_callback_http.listener_arn
  target_group_arn  = module.tg_callback.arn
  host_header       = local.callback_hostname
  priority          = "1"
}

module "listener_callback_https" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener"

  lb_arn          = module.alb_callback.arn
  port            = 443
  protocol        = "HTTPS"
  ssl_policy      = var.ssl_policy
  certificate_arn = data.aws_acm_certificate.wildcard.arn

  tags = merge(local.common_tags, {
    Name = "smartvault-${local.env_id}-listener-callback-https"
  })
}

module "listener_rule_callback_https" {
  source = "./sv-modules/smartvault-terraform-aws-loadbalancer-listener-rule"

  listener_arn      = module.listener_callback_https.listener_arn
  target_group_arn  = module.tg_callback.arn
  host_header       = local.callback_hostname
  priority          = "1"
}

# ==============================================================================
# AUTO SCALING GROUPS - Using org-module-fixes (No org module available)
# ==============================================================================

# ==============================================================================
# AUTO SCALING GROUPS - Using org-module-fixes (No org module available)
# ==============================================================================

module "asg_portal" {
  source = "./org-module-fixes/asg"

  name                 = "smartvault-${local.env_id}-ec2-asg-ASMPortal${local.blue_green_suffix}"
  ami_id               = var.portal_ami_id
  instance_type        = local.portal_instance_type
  key_name             = local.keypair
  iam_instance_profile = module.iam.instance_profile_name
  security_groups      = [module.sg_portal_ec2.security_group_id]
  subnet_ids           = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  target_group_arns    = [module.tg_portal.arn]
  min_size             = var.asg_min
  desired_capacity     = var.asg_desired
  max_size             = var.asg_max
  enable_monitoring    = local.instance_monitoring

  # User data configuration
  user_data_template_file = "${path.module}/org-module-fixes/asg/user-data/portal.sh.tpl"
  user_data_template_vars = {
    env_id            = local.env_id
    mfa_version       = var.mfa_version
    db_password       = var.db_password
    rds_endpoint      = local.rds_hostname
    secret_key_twilio = var.secret_key_twilio
    callback_url      = "https://${local.callback_hostname}/asm_callback/twilio.ap"
    jvm_xms           = local.jvm_heap_config.xms
    jvm_xmx           = local.jvm_heap_config.xmx
    aws_region        = var.aws_region
    asg_name          = "smartvault-${local.env_id}-ec2-asg-ASMPortal${local.blue_green_suffix}"
  }

  # Tag specifications for instances
  tag_specifications = [{
    resource_type = "instance"
    tags = {
      Name      = "smartvault-${local.env_id}-ec2-asg-ASMPortal${local.blue_green_suffix}"
      Component = "Portal"
    }
  }]

  # ASG tags
  asg_tags = {
    Name = {
      value               = "smartvault-${local.env_id}-ec2-asg-ASMPortal${local.blue_green_suffix}"
      propagate_at_launch = true
    }
    Component = {
      value               = "Portal"
      propagate_at_launch = true
    }
  }

  # Scheduled scaling
  autoscaling_schedules = var.cost_saving_enabled ? {
    scale_up = {
      min_size         = var.asg_min
      max_size         = var.asg_max
      desired_capacity = var.asg_desired
      recurrence       = var.weekly_schedule_up
    }
    scale_down = {
      min_size         = 0
      max_size         = 2
      desired_capacity = 0
      recurrence       = var.weekend_schedule_down
    }
  } : {}

  tags = local.common_tags
}

module "asg_webapps" {
  source = "./org-module-fixes/asg"

  name                  = "smartvault-${local.env_id}-ec2-asg-ASMWebApps${local.blue_green_suffix}"
  ami_id                = var.webapps_ami_id
  instance_type         = local.webapps_instance_type
  key_name              = local.keypair
  iam_instance_profile  = module.iam.instance_profile_name
  security_groups       = [module.sg_webapps_ec2.security_group_id]
  subnet_ids            = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  target_group_arns     = [module.tg_webapps.arn]
  min_size              = var.asg_min
  desired_capacity      = var.asg_desired
  max_size              = var.webapps_asg_max
  enable_monitoring     = local.instance_monitoring

  # User data configuration
  user_data_template_file = "${path.module}/org-module-fixes/asg/user-data/webapps.sh.tpl"
  user_data_template_vars = {
    env_id            = local.env_id
    mfa_version       = var.mfa_version
    db_password       = var.db_password
    rds_endpoint      = local.rds_hostname
    secret_key_twilio = var.secret_key_twilio
    callback_url      = "https://${local.callback_hostname}/asm_callback/twilio.ap"
    upgrade_db        = var.upgrade_db
    jvm_xms           = local.jvm_heap_config.xms
    jvm_xmx           = local.jvm_heap_config.xmx
    aws_region        = var.aws_region
    asg_name          = "smartvault-${local.env_id}-ec2-asg-ASMWebApps${local.blue_green_suffix}"
  }

  # Tag specifications for instances
  tag_specifications = [{
    resource_type = "instance"
    tags = {
      Name      = "smartvault-${local.env_id}-ec2-asg-ASMWebApps${local.blue_green_suffix}"
      Component = "WebApps"
    }
  }]

  # ASG tags
  asg_tags = {
    Name = {
      value               = "smartvault-${local.env_id}-ec2-asg-ASMWebApps${local.blue_green_suffix}"
      propagate_at_launch = true
    }
    Component = {
      value               = "WebApps"
      propagate_at_launch = true
    }
  }

  # Target tracking scaling for memory
  enable_target_tracking_scaling = true
  target_tracking_configuration = {
    customized_metric_specification = {
      namespace     = "System/Linux"
      metric_name   = "MemoryUtilization"
      statistic     = "Average"
      unit          = "Percent"
      metric_dimensions = [{
        name  = "AutoScalingGroupName"
        value = "smartvault-${local.env_id}-ec2-asg-ASMWebApps${local.blue_green_suffix}"
      }]
    }
    target_value = 80.0
  }

  # Scheduled scaling
  autoscaling_schedules = var.cost_saving_enabled ? {
    scale_up = {
      min_size         = var.asg_min
      max_size         = var.webapps_asg_max
      desired_capacity = var.asg_desired
      recurrence       = var.weekly_schedule_up
    }
    scale_down = {
      min_size         = 0
      max_size         = 2
      desired_capacity = 0
      recurrence       = var.weekend_schedule_down
    }
  } : {}

  tags = local.common_tags
}


module "asg_callback" {
  source = "./org-module-fixes/asg"

  name                 = "smartvault-${local.env_id}-ec2-asg-ASMCallback${local.blue_green_suffix}"
  ami_id               = var.callback_ami_id
  instance_type        = local.callback_instance_type
  key_name             = local.keypair
  iam_instance_profile = module.iam.instance_profile_name
  security_groups      = [module.sg_callback_ec2.security_group_id]
  subnet_ids           = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  target_group_arns    = [module.tg_callback.arn]
  min_size             = var.asg_min
  desired_capacity     = var.asg_desired
  max_size             = var.asg_max
  enable_monitoring    = local.instance_monitoring

  # User data configuration
  user_data_template_file = "${path.module}/org-module-fixes/asg/user-data/callback.sh.tpl"
  user_data_template_vars = {
    secret_key_twilio = var.secret_key_twilio
    jvm_xms           = local.jvm_heap_config.xms
    jvm_xmx           = local.jvm_heap_config.xmx
    aws_region        = var.aws_region
    asg_name          = "smartvault-${local.env_id}-ec2-asg-ASMCallback${local.blue_green_suffix}"
  }

  # Tag specifications for instances
  tag_specifications = [{
    resource_type = "instance"
    tags = {
      Name      = "smartvault-${local.env_id}-ec2-asg-ASMCallback${local.blue_green_suffix}"
      Component = "Callback"
    }
  }]

  # ASG tags
  asg_tags = {
    Name = {
      value               = "smartvault-${local.env_id}-ec2-asg-ASMCallback${local.blue_green_suffix}"
      propagate_at_launch = true
    }
    Component = {
      value               = "Callback"
      propagate_at_launch = true
    }
  }

  # Scheduled scaling
  autoscaling_schedules = var.cost_saving_enabled ? {
    scale_up = {
      min_size         = var.asg_min
      max_size         = var.asg_max
      desired_capacity = var.asg_desired
      recurrence       = var.weekly_schedule_up
    }
    scale_down = {
      min_size         = 0
      max_size         = 2
      desired_capacity = 0
      recurrence       = var.weekend_schedule_down
    }
  } : {}

  tags = local.common_tags
}


# ==============================================================================
# CLOUDWATCH ALARMS - Using org-module-fixes (No org module available)
# ==============================================================================

# Portal CPU Alarm
module "alarm_portal_cpu" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMPortal-HighCPU"
  alarm_description   = "High CPU usage alarm for ASMPortal in ${local.env_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  actions_enabled     = var.alarms_enabled
  dimensions          = { AutoScalingGroupName = module.asg_portal.asg_name }
  alarm_actions       = [data.aws_sns_topic.alerts.arn]
  ok_actions          = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# Portal Disk Alarm
module "alarm_portal_disk" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMPortal-LowFreeSpace"
  alarm_description   = "Low disk space alarm for ASMPortal in ${local.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 1000
  actions_enabled     = var.alarms_enabled
  metric_queries = [{
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "DiskFree(/)-MB"
    return_data = true
    metric      = null
  }, {
    id          = "m1"
    expression  = null
    return_data = false
    metric = {
      metric_name = "DiskFree - /"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions  = { AutoScalingGroupName = module.asg_portal.asg_name }
    }
  }]
  alarm_actions             = [data.aws_sns_topic.alerts.arn]
  ok_actions                = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# Portal Memory Alarm
module "alarm_portal_memory" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMPortal-LowAvailableMemory"
  alarm_description   = "Low available memory alarm for ASMPortal in ${local.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 512
  actions_enabled     = var.alarms_enabled
  metric_queries = [{
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "MemAvailable-MB"
    return_data = true
    metric      = null
  }, {
    id          = "m1"
    expression  = null
    return_data = false
    metric = {
      metric_name = "MemAvailable"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions  = { AutoScalingGroupName = module.asg_portal.asg_name }
    }
  }]
  alarm_actions             = [data.aws_sns_topic.alerts.arn]
  ok_actions                = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# Portal Status Alarm
module "alarm_portal_status" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "${module.asg_portal.asg_name}: ASM Portal Status"
  alarm_description   = "${module.asg_portal.asg_name}: ASM Portal Status"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 5
  metric_name         = "ASMPortalStatus"
  namespace           = "System/Linux"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  actions_enabled     = var.alarms_enabled
  dimensions          = { AutoScalingGroupName = module.asg_portal.asg_name }
  alarm_actions       = [data.aws_sns_topic.alerts.arn]
  ok_actions          = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# WebApps CPU Alarm
module "alarm_webapps_cpu" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMWebApps-HighCPU"
  alarm_description   = "High CPU usage alarm for ASMWebApps in ${local.env_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  actions_enabled     = var.alarms_enabled
  dimensions          = { AutoScalingGroupName = module.asg_webapps.asg_name }
  alarm_actions       = [data.aws_sns_topic.alerts.arn]
  ok_actions          = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# WebApps Memory Percent Alarm
module "alarm_webapps_memory_percent" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMWebApps-Memutilizationpercent"
  alarm_description   = "Memory utilization percentage alarm for ASMWebApps in ${local.env_id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  actions_enabled     = var.alarms_enabled
  dimensions          = { AutoScalingGroupName = module.asg_webapps.asg_name }
  alarm_actions       = [data.aws_sns_topic.alerts.arn]
  ok_actions          = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# WebApps Disk Alarm
module "alarm_webapps_disk" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMWebApps-LowFreeSpace"
  alarm_description   = "Low disk space alarm for ASMWebApps in ${local.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 1000
  actions_enabled     = var.alarms_enabled
  metric_queries = [{
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "DiskFree(/)-MB"
    return_data = true
    metric      = null
  }, {
    id          = "m1"
    expression  = null
    return_data = false
    metric = {
      metric_name = "DiskFree - /"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions  = { AutoScalingGroupName = module.asg_webapps.asg_name }
    }
  }]
  alarm_actions             = [data.aws_sns_topic.alerts.arn]
  ok_actions                = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# WebApps Memory Alarm
module "alarm_webapps_memory" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMWebApps-LowAvailableMemory"
  alarm_description   = "Low available memory alarm for ASMWebApps in ${local.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 512
  actions_enabled     = var.alarms_enabled
  metric_queries = [{
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "MemAvailable-MB"
    return_data = true
    metric      = null
  }, {
    id          = "m1"
    expression  = null
    return_data = false
    metric = {
      metric_name = "MemAvailable"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions  = { AutoScalingGroupName = module.asg_webapps.asg_name }
    }
  }]
  alarm_actions             = [data.aws_sns_topic.alerts.arn]
  ok_actions                = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# Callback CPU Alarm
module "alarm_callback_cpu" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMCallback-HighCPU"
  alarm_description   = "High CPU usage alarm for ASMCallback in ${local.env_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  actions_enabled     = var.alarms_enabled
  dimensions          = { AutoScalingGroupName = module.asg_callback.asg_name }
  alarm_actions       = [data.aws_sns_topic.alerts.arn]
  ok_actions          = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# Callback Disk Alarm
module "alarm_callback_disk" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMCallback-LowFreeSpace"
  alarm_description   = "Low disk space alarm for ASMCallback in ${local.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 1000
  actions_enabled     = var.alarms_enabled
  metric_queries = [{
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "DiskFree(/)-MB"
    return_data = true
    metric      = null
  }, {
    id          = "m1"
    expression  = null
    return_data = false
    metric = {
      metric_name = "DiskFree - /"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions  = { AutoScalingGroupName = module.asg_callback.asg_name }
    }
  }]
  alarm_actions             = [data.aws_sns_topic.alerts.arn]
  ok_actions                = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}

# Callback Memory Alarm
module "alarm_callback_memory" {
  source = "./org-module-fixes/cloudwatch-alarms"

  alarm_name          = "smartvault-${local.env_id}-ASMCallback-LowAvailableMemory"
  alarm_description   = "Low available memory alarm for ASMCallback in ${local.env_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 5
  threshold           = 512
  actions_enabled     = var.alarms_enabled
  metric_queries = [{
    id          = "e1"
    expression  = "m1/(1000^2)"
    label       = "MemAvailable-MB"
    return_data = true
    metric      = null
  }, {
    id          = "m1"
    expression  = null
    return_data = false
    metric = {
      metric_name = "MemAvailable"
      namespace   = "System/Linux"
      period      = 60
      stat        = "Average"
      unit        = "Bytes"
      dimensions  = { AutoScalingGroupName = module.asg_callback.asg_name }
    }
  }]
  alarm_actions             = [data.aws_sns_topic.alerts.arn]
  ok_actions                = [data.aws_sns_topic.alerts.arn]
  insufficient_data_actions = [data.aws_sns_topic.alerts.arn]
}


# ==============================================================================
# ROUTE53 RECORDS - Using Org Module
# ==============================================================================

module "route53_portal" {
  source = "./sv-modules/smartvault-terraform-aws-route53-record"

  record_enabled = true
  zone_id        = data.aws_route53_zone.internal.zone_id
  name           = local.portal_hostname
  type           = "A"

  alias = {
    name                   = module.alb_portal.dns_name
    zone_id                = module.alb_portal.zone_id
    evaluate_target_health = "false"
  }
}

module "route53_webapps" {
  source = "./sv-modules/smartvault-terraform-aws-route53-record"

  record_enabled = true
  zone_id        = data.aws_route53_zone.internal.zone_id
  name           = local.webapps_hostname
  type           = "A"

  alias = {
    name                   = module.alb_webapps.dns_name
    zone_id                = module.alb_webapps.zone_id
    evaluate_target_health = "false"
  }
}

module "route53_callback" {
  source = "./sv-modules/smartvault-terraform-aws-route53-record"

  record_enabled = true
  zone_id        = data.aws_route53_zone.public.zone_id
  name           = local.callback_hostname
  type           = "A"

  alias = {
    name                   = module.alb_callback.dns_name
    zone_id                = module.alb_callback.zone_id
    evaluate_target_health = "false"
  }
}

module "route53_rds" {
  source = "./sv-modules/smartvault-terraform-aws-route53-record"

  record_enabled = true
  zone_id        = data.aws_route53_zone.internal.zone_id
  name           = local.rds_hostname
  type           = "CNAME"
  ttl            = "300"
  records        = [module.rds.db_instance_address]
}
