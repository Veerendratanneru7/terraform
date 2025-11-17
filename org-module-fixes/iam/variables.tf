variable "env_id" {
  type = string
}

variable "account_id" {
  type = string
}

variable "is_production" {
  type = bool
}

variable "restricted_users" {
  type    = list(string)
  default = []
}

variable "log_group_arns" {
  type = list(string)
}

