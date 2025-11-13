module "cloudwatch_logs" {
  source = "./modules/cloudwatch-logs"

  env_id = local.env_id
}

module "iam" {
  source = "./modules/iam"

  env_id            = local.env_id
  account_id        = local.account_id
  is_production     = local.is_production
  restricted_users  = var.restricted_users
  log_group_arns    = module.cloudwatch_logs.log_group_arns
}

module "security_groups" {
  source = "./modules/security-groups"

  env_id                  = local.env_id
  vpc_id                  = data.aws_vpc.main.id
  remoteadmin_sg_id       = data.aws_security_group.remoteadmin.id
  ec2_webserver_sg_id     = data.aws_security_group.ec2_webserver.id
}

module "rds" {
  source = "./modules/rds"

  env_id               = local.env_id
  db_username          = var.db_username
  db_password          = var.db_password
  mysql_engine_version = var.mysql_engine_version
  storage_type         = var.rds_storage_type
  subnet_ids           = [data.aws_subnet.private_data_1.id, data.aws_subnet.private_data_2.id]
  security_group_ids   = [data.aws_security_group.rds_mfa.id]
  portal_sg_id         = module.security_groups.portal_ec2_sg_id
  webapps_sg_id        = module.security_groups.webapps_ec2_sg_id
}

module "alb_portal" {
  source = "./modules/load-balancer"

  name                     = "smartvault-${local.env_id}-intalb-portal-mfa${local.blue_green_suffix}"
  internal                 = true
  vpc_id                   = data.aws_vpc.main.id
  subnets                  = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  security_groups          = [module.security_groups.portal_alb_sg_id]
  certificate_arn          = local.certificate_arn
  ssl_policy               = var.ssl_policy
  deregistration_delay     = local.alb_deregistration_delay
  health_check_path        = "/asm_portal/login.ap"
  health_check_port        = 8080
  listener_port            = 8080
  target_port              = 8080
  enable_https             = true
  hostname                 = local.portal_hostname
  account_id               = local.account_id
}

module "alb_webapps" {
  source = "./modules/load-balancer"

  name                     = "smartvault-${local.env_id}-intalb-webapp-mfa${local.blue_green_suffix}"
  internal                 = true
  vpc_id                   = data.aws_vpc.main.id
  subnets                  = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  security_groups          = [module.security_groups.webapps_alb_sg_id]
  certificate_arn          = local.certificate_arn
  ssl_policy               = var.ssl_policy
  deregistration_delay     = local.alb_deregistration_delay
  health_check_path        = "/health/index.html"
  health_check_port        = 8080
  listener_port            = 8080
  target_port              = 8080
  enable_https             = false
  hostname                 = local.webapps_hostname
  account_id               = local.account_id
}

module "alb_callback" {
  source = "./modules/load-balancer"

  name                     = "smartvault-${local.env_id}-alb-callback-mfa${local.blue_green_suffix}"
  internal                 = false
  vpc_id                   = data.aws_vpc.main.id
  subnets                  = [data.aws_subnet.public_1.id, data.aws_subnet.public_2.id]
  security_groups          = [module.security_groups.callback_alb_sg_id]
  certificate_arn          = data.aws_acm_certificate.wildcard.arn
  ssl_policy               = var.ssl_policy
  deregistration_delay     = local.alb_deregistration_delay
  health_check_path        = "/health/index.html"
  health_check_port        = 8080
  listener_port            = 80
  target_port              = 8080
  enable_https             = true
  hostname                 = local.callback_hostname
  account_id               = local.account_id
}

module "asg_portal" {
  source = "./modules/asg"

  name                 = "smartvault-${local.env_id}-ec2-asg-ASMPortal${local.blue_green_suffix}"
  component            = "portal"
  ami_id               = var.portal_ami_id
  instance_type        = local.portal_instance_type
  key_name             = local.keypair
  iam_instance_profile = module.iam.instance_profile_name
  security_groups      = [module.security_groups.portal_ec2_sg_id]
  subnet_ids           = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  target_group_arns    = [module.alb_portal.target_group_arn]
  min_size             = var.asg_min
  desired_capacity     = var.asg_desired
  max_size             = var.asg_max
  enable_monitoring    = local.instance_monitoring
  env_id               = local.env_id
  mfa_version          = var.mfa_version
  db_password          = var.db_password
  rds_endpoint         = local.rds_hostname
  secret_key_twilio    = var.secret_key_twilio
  callback_url         = "https://${local.callback_hostname}/asm_callback/twilio.ap"
  schedule_enabled     = var.cost_saving_enabled
  schedule_up          = var.weekly_schedule_up
  schedule_down        = var.weekend_schedule_down
  jvm_xms              = local.jvm_heap_config.xms
  jvm_xmx              = local.jvm_heap_config.xmx
  aws_region           = var.aws_region
}

module "asg_webapps" {
  source = "./modules/asg"

  name                 = "smartvault-${local.env_id}-ec2-asg-ASMWebApps${local.blue_green_suffix}"
  component            = "webapps"
  ami_id               = var.webapps_ami_id
  instance_type        = local.webapps_instance_type
  key_name             = local.keypair
  iam_instance_profile = module.iam.instance_profile_name
  security_groups      = [module.security_groups.webapps_ec2_sg_id]
  subnet_ids           = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  target_group_arns    = [module.alb_webapps.target_group_arn]
  min_size             = var.asg_min
  desired_capacity     = var.asg_desired
  max_size             = var.webapps_asg_max
  enable_monitoring    = local.instance_monitoring
  env_id               = local.env_id
  mfa_version          = var.mfa_version
  db_password          = var.db_password
  rds_endpoint         = local.rds_hostname
  secret_key_twilio    = var.secret_key_twilio
  callback_url         = "https://${local.callback_hostname}/asm_callback/twilio.ap"
  schedule_enabled     = var.cost_saving_enabled
  schedule_up          = var.weekly_schedule_up
  schedule_down        = var.weekend_schedule_down
  upgrade_db           = var.upgrade_db
  jvm_xms              = local.jvm_heap_config.xms
  jvm_xmx              = local.jvm_heap_config.xmx
  aws_region           = var.aws_region
  enable_memory_scaling = true
}

module "asg_callback" {
  source = "./modules/asg"

  name                 = "smartvault-${local.env_id}-ec2-asg-ASMCallback${local.blue_green_suffix}"
  component            = "callback"
  ami_id               = var.callback_ami_id
  instance_type        = local.callback_instance_type
  key_name             = local.keypair
  iam_instance_profile = module.iam.instance_profile_name
  security_groups      = [module.security_groups.callback_ec2_sg_id]
  subnet_ids           = [data.aws_subnet.private_app_1.id, data.aws_subnet.private_app_2.id]
  target_group_arns    = [module.alb_callback.target_group_arn]
  min_size             = var.asg_min
  desired_capacity     = var.asg_desired
  max_size             = var.asg_max
  enable_monitoring    = local.instance_monitoring
  env_id               = local.env_id
  mfa_version          = var.mfa_version
  secret_key_twilio    = var.secret_key_twilio
  schedule_enabled     = var.cost_saving_enabled
  schedule_up          = var.weekly_schedule_up
  schedule_down        = var.weekend_schedule_down
  jvm_xms              = local.jvm_heap_config.xms
  jvm_xmx              = local.jvm_heap_config.xmx
  aws_region           = var.aws_region
}

module "cloudwatch_alarms" {
  source = "./modules/cloudwatch-alarms"

  env_id                  = local.env_id
  alarms_enabled          = var.alarms_enabled
  sns_topic_arn           = data.aws_sns_topic.alerts.arn
  portal_asg_name         = module.asg_portal.asg_name
  webapps_asg_name        = module.asg_webapps.asg_name
  callback_asg_name       = module.asg_callback.asg_name
}

module "route53" {
  source = "./modules/route53"

  env_id                = local.env_id
  internal_zone_id      = data.aws_route53_zone.internal.zone_id
  public_zone_id        = data.aws_route53_zone.public.zone_id
  portal_alb_dns        = module.alb_portal.alb_dns_name
  portal_alb_zone_id    = module.alb_portal.alb_zone_id
  webapps_alb_dns       = module.alb_webapps.alb_dns_name
  webapps_alb_zone_id   = module.alb_webapps.alb_zone_id
  callback_alb_dns      = module.alb_callback.alb_dns_name
  callback_alb_zone_id  = module.alb_callback.alb_zone_id
  rds_endpoint          = module.rds.endpoint
  portal_hostname       = local.portal_hostname
  webapps_hostname      = local.webapps_hostname
  callback_hostname     = local.callback_hostname
  rds_hostname          = local.rds_hostname
}
