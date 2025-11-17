# Alarm Configuration
variable "alarm_name" {
  description = "The descriptive name for the alarm"
  type        = string
}

variable "alarm_description" {
  description = "The description for the alarm"
  type        = string
  default     = ""
}

variable "comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold"
  type        = string
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = number
}

variable "threshold" {
  description = "The value against which the specified statistic is compared"
  type        = number
}

variable "actions_enabled" {
  description = "Indicates whether or not actions should be executed during any changes to the alarm's state"
  type        = bool
  default     = true
}

variable "treat_missing_data" {
  description = "Sets how this alarm is to handle missing data points"
  type        = string
  default     = "missing"
}

# Simple Metric Configuration
variable "metric_name" {
  description = "The name for the alarm's associated metric"
  type        = string
  default     = null
}

variable "namespace" {
  description = "The namespace for the alarm's associated metric"
  type        = string
  default     = null
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = number
  default     = null
}

variable "statistic" {
  description = "The statistic to apply to the alarm's associated metric"
  type        = string
  default     = null
}

variable "unit" {
  description = "The unit for the alarm's associated metric"
  type        = string
  default     = null
}

variable "dimensions" {
  description = "The dimensions for the alarm's associated metric"
  type        = map(string)
  default     = {}
}

# Complex Metric Queries (for disk/memory with expressions)
variable "metric_queries" {
  description = "Enables you to create an alarm based on a metric math expression"
  type = list(object({
    id          = string
    expression  = optional(string)
    label       = optional(string)
    return_data = optional(bool)
    metric = optional(object({
      metric_name = string
      namespace   = string
      period      = number
      stat        = string
      unit        = optional(string)
      dimensions  = optional(map(string))
    }))
  }))
  default = []
}

# Actions
variable "alarm_actions" {
  description = "The list of actions to execute when this alarm transitions into an ALARM state"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "The list of actions to execute when this alarm transitions into an OK state"
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

