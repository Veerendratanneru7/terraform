variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "owner" {
  type    = string
  default = "devops@smartvault.com"
}

variable "portal_ami_id" {
  type = string
}

variable "webapps_ami_id" {
  type = string
}

variable "callback_ami_id" {
  type = string
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "upgrade_db" {
  type    = bool
  default = false
}

variable "mysql_engine_version" {
  type    = string
  default = "5.7.44-RDS.20240808"
}

variable "rds_storage_type" {
  type    = string
  default = "gp3"
}

variable "asg_min" {
  type    = number
  default = 1
}

variable "asg_desired" {
  type    = number
  default = 1
}

variable "asg_max" {
  type    = number
  default = 1
}

variable "webapps_asg_max" {
  type    = number
  default = 5
}

variable "mfa_version" {
  type    = string
  default = "3.3.0"
}

variable "secret_key_twilio" {
  type      = string
  sensitive = true
}

variable "db_username" {
  type    = string
  default = "root"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "weekly_schedule_up" {
  type    = string
  default = "15 13 * * 1-5"
}

variable "weekend_schedule_down" {
  type    = string
  default = "15 3 * * 6"
}

variable "cost_saving_enabled" {
  type    = bool
  default = false
}

variable "alarms_enabled" {
  type    = bool
  default = true
}

variable "restricted_users" {
  type    = list(string)
  default = []
}

variable "deployment_color" {
  type        = string
  default     = "blue"
  description = "Current deployment color for blue-green deployments"

  validation {
    condition     = contains(["blue", "green"], var.deployment_color)
    error_message = "Deployment color must be either 'blue' or 'green'"
  }
}

variable "enable_green_deployment" {
  type        = bool
  default     = false
  description = "Enable green environment for blue-green deployment"
}
