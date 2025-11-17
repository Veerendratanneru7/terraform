# CloudWatch Log Group - Using organizational module or creating directly
resource "aws_cloudwatch_log_group" "this" {
  count = var.use_organizational_module ? 0 : 1

  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  skip_destroy      = var.skip_destroy
  log_group_class   = var.log_group_class

  tags = var.tags
}

# Optional: Use organizational CloudWatch module
module "log_group" {
  count = var.use_organizational_module ? 1 : 0

  source = var.organizational_module_source

  log_group_name    = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  skip_destroy      = var.skip_destroy
  log_group_class   = var.log_group_class

  tags = var.tags
}

locals {
  log_group_name = var.use_organizational_module ? module.log_group[0].log_group_this_name : aws_cloudwatch_log_group.this[0].name
}

# Data Protection Policy for PII/OTP masking
resource "aws_cloudwatch_log_data_protection_policy" "this" {
  count = var.enable_data_protection ? 1 : 0

  log_group_name = local.log_group_name

  policy_document = var.custom_data_protection_policy != null ? var.custom_data_protection_policy : jsonencode({
    Name    = "${var.log_group_name}-data-protection"
    Version = "2021-06-01"

    Statement = concat(
      var.mask_pii_data ? [{
        Sid            = "MaskPIIData"
        DataIdentifier = var.pii_data_identifiers
        Operation = {
          Audit = {
            FindingsDestination = var.audit_findings_destination
          }
          Deidentify = {
            MaskConfig = var.mask_config
          }
        }
      }] : [],
      var.mask_custom_data ? [{
        Sid            = "MaskCustomData"
        DataIdentifier = []
        Operation = {
          Audit = {
            FindingsDestination = var.audit_findings_destination
          }
          Deidentify = {
            MaskConfig = var.mask_config
          }
        }
      }] : []
    )

    Configuration = {
      CustomDataIdentifiers = var.custom_data_identifiers
    }
  })
}

