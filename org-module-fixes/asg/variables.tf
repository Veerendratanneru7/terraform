variable "name" {
  type = string
}

variable "component" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}

variable "min_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "enable_monitoring" {
  type = bool
}

variable "env_id" {
  type = string
}

variable "mfa_version" {
  type    = string
  default = ""
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "rds_endpoint" {
  type    = string
  default = ""
}

variable "secret_key_twilio" {
  type      = string
  sensitive = true
  default   = ""
}

variable "callback_url" {
  type    = string
  default = ""
}

variable "schedule_enabled" {
  type    = bool
  default = false
}

variable "schedule_up" {
  type    = string
  default = ""
}

variable "schedule_down" {
  type    = string
  default = ""
}

variable "upgrade_db" {
  type    = bool
  default = false
}

variable "jvm_xms" {
  type = string
}

variable "jvm_xmx" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "enable_memory_scaling" {
  type    = bool
  default = false
}
