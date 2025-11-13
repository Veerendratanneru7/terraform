locals {
  account_id     = data.aws_caller_identity.current.account_id
  is_production  = local.account_id == "587105464662"
  is_staging     = local.account_id == "450560603497"
  is_development = local.account_id == "764285433653"

  environment = local.is_production ? "prod" : (local.is_staging ? "staging" : "dev")

  environment_config = {
    "764285433653" = {
      env_id                     = "dev"
      domain                     = "dev.smartvault.com"
      certificate_arn            = "arn:aws:acm:us-east-2:764285433653:certificate/d45c14a1-f9bf-4243-839c-8c7ee0a018de"
      keypair                    = "smartvault-development-us-east-2"
      instance_monitoring        = true
      alb_deregistration_delay   = 0
      enable_hostname_prefix     = false
      portal_instance_type       = "t3.medium"
      webapps_instance_type      = "t3.medium"
      callback_instance_type     = "t3.medium"
    }
    "450560603497" = {
      env_id                     = "staging"
      domain                     = "stg.smartvault.com"
      certificate_arn            = "arn:aws:acm:us-east-2:450560603497:certificate/277c9eb7-b53c-4284-9f75-8f57976f464f"
      keypair                    = "smartvault-staging-us-east-2"
      instance_monitoring        = true
      alb_deregistration_delay   = 0
      enable_hostname_prefix     = false
      portal_instance_type       = "t3.medium"
      webapps_instance_type      = "t3.medium"
      callback_instance_type     = "t3.medium"
    }
    "587105464662" = {
      env_id                     = "prod"
      domain                     = "smartvault.com"
      certificate_arn            = "arn:aws:acm:us-east-2:587105464662:certificate/281fb180-96f2-4cdb-9cf7-cab1741634ad"
      keypair                    = "smartvault-production-us-east-2"
      instance_monitoring        = true
      alb_deregistration_delay   = 300
      enable_hostname_prefix     = false
      portal_instance_type       = "t3.large"
      webapps_instance_type      = "t3.large"
      callback_instance_type     = "t3.medium"
    }
  }

  env_config                 = local.environment_config[local.account_id]
  env_id                     = local.env_config.env_id
  domain                     = local.env_config.domain
  certificate_arn            = local.env_config.certificate_arn
  keypair                    = local.env_config.keypair
  instance_monitoring        = local.env_config.instance_monitoring
  alb_deregistration_delay   = local.env_config.alb_deregistration_delay
  enable_hostname_prefix     = local.env_config.enable_hostname_prefix
  portal_instance_type       = local.env_config.portal_instance_type
  webapps_instance_type      = local.env_config.webapps_instance_type
  callback_instance_type     = local.env_config.callback_instance_type

  hostname_prefix            = local.enable_hostname_prefix ? "${local.env_id}-" : ""
  
  portal_hostname            = "${local.hostname_prefix}mfa.int.${local.domain}"
  webapps_hostname           = "${local.hostname_prefix}asm.int.${local.domain}"
  callback_hostname          = "${local.hostname_prefix}asm-callback.${local.domain}"
  rds_hostname               = "${local.hostname_prefix}mfadb.int.${local.domain}"

  jvm_heap_config = (local.is_development || local.is_staging) ? {
    xms = "512M"
    xmx = "2048M"
  } : {
    xms = "512M"
    xmx = "2048M"
  }

  common_tags = {
    Environment = local.env_id
  }

  blue_green_suffix = var.enable_green_deployment ? "-${var.deployment_color}" : ""
}
