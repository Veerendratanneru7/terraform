variable "name" {
  type = string
}

variable "internal" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "deregistration_delay" {
  type    = number
  default = 300
}

variable "health_check_path" {
  type = string
}

variable "health_check_port" {
  type = number
}

variable "listener_port" {
  type = number
}

variable "target_port" {
  type = number
}

variable "enable_https" {
  type    = bool
  default = false
}

variable "hostname" {
  type    = string
  default = ""
}

variable "account_id" {
  type = string
}
