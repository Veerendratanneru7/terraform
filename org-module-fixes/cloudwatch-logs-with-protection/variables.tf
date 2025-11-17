# Log Group Configuration
variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "retention_in_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "kms_key_id" {
  description = "KMS key ID for log encryption"
  type        = string
  default     = null
}

variable "skip_destroy" {
  description = "Set to true if you do not wish the log group to be deleted at destroy time"
  type        = bool
  default     = false
}

variable "log_group_class" {
  description = "Specified the log class of the log group. Possible values are: STANDARD or INFREQUENT_ACCESS"
  type        = string
  default     = "STANDARD"
}

variable "tags" {
  description = "Tags to apply to the log group"
  type        = map(string)
  default     = {}
}

# Module Configuration
variable "use_organizational_module" {
  description = "Whether to use the organizational CloudWatch module or create log group directly"
  type        = bool
  default     = false
}

variable "organizational_module_source" {
  description = "Source path for the organizational CloudWatch module (required if use_organizational_module is true)"
  type        = string
  default     = "../../sv-modules/smartvault-terraform-aws-cloudwatch"
}

# Data Protection Configuration
variable "enable_data_protection" {
  description = "Enable data protection policy for PII/OTP masking"
  type        = bool
  default     = true
}

variable "custom_data_protection_policy" {
  description = "Custom data protection policy JSON (if provided, overrides default policy)"
  type        = string
  default     = null
}

variable "mask_pii_data" {
  description = "Enable masking of PII data (emails, addresses, keys, etc.)"
  type        = bool
  default     = true
}

variable "pii_data_identifiers" {
  description = "List of AWS data identifiers for PII data to mask"
  type        = list(string)
  default = [
    "arn:aws:dataprotection::aws:data-identifier/EmailAddress",
    "arn:aws:dataprotection::aws:data-identifier/Address",
    "arn:aws:dataprotection::aws:data-identifier/AwsSecretKey",
    "arn:aws:dataprotection::aws:data-identifier/OpenSshPrivateKey",
    "arn:aws:dataprotection::aws:data-identifier/PgpPrivateKey",
    "arn:aws:dataprotection::aws:data-identifier/PkcsPrivateKey",
    "arn:aws:dataprotection::aws:data-identifier/PuttyPrivateKey",
  ]
}

variable "mask_custom_data" {
  description = "Enable masking of custom data patterns (OTP codes, etc.)"
  type        = bool
  default     = true
}

variable "custom_data_identifiers" {
  description = "List of custom data identifiers for pattern-based masking"
  type = list(object({
    Name  = string
    Regex = string
  }))
  default = [
    {
      Name  = "OTP_6_DIGITS"
      Regex = "(?i)(otp|code|verification code|passcode)\\s*[:=]?\\s*([0-9]{6})"
    },
    {
      Name  = "TWILIO_PASSCODE"
      Regex = "(?i)(twilio passcode|verification code from twilio)\\s*[:=]?\\s*([0-9]{6})"
    }
  ]
}

variable "audit_findings_destination" {
  description = "Destination for audit findings (CloudWatch Logs, S3, Firehose)"
  type        = map(any)
  default     = {}
}

variable "mask_config" {
  description = "Configuration for masking (empty object uses default masking)"
  type        = map(any)
  default     = {}
}

