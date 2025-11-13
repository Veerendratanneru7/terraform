variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "enable_data_protection" {
  description = "Enable data protection policy for PII/OTP masking"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for log encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the log group"
  type        = map(string)
  default     = {}
}
