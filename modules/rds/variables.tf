variable "env_id" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "mysql_engine_version" {
  type = string
}

variable "storage_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "portal_sg_id" {
  type = string
}

variable "webapps_sg_id" {
  type = string
}
