variable "env_id" {
  type = string
}

variable "alarms_enabled" {
  type = bool
}

variable "sns_topic_arn" {
  type = string
}

variable "portal_asg_name" {
  type = string
}

variable "webapps_asg_name" {
  type = string
}

variable "callback_asg_name" {
  type = string
}
