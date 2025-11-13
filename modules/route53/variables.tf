variable "env_id" {
  type = string
}

variable "internal_zone_id" {
  type = string
}

variable "public_zone_id" {
  type = string
}

variable "portal_alb_dns" {
  type = string
}

variable "portal_alb_zone_id" {
  type = string
}

variable "webapps_alb_dns" {
  type = string
}

variable "webapps_alb_zone_id" {
  type = string
}

variable "callback_alb_dns" {
  type = string
}

variable "callback_alb_zone_id" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "portal_hostname" {
  type = string
}

variable "webapps_hostname" {
  type = string
}

variable "callback_hostname" {
  type = string
}

variable "rds_hostname" {
  type = string
}
