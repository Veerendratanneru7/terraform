# Use the organizational CloudWatch module
module "log_group" {
  source = "../../123/smartvault-terraform-aws-cloudwatch"

  log_group_name    = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_id
  
  tags = var.tags
}

# Add data protection policy for PII/OTP masking
resource "aws_cloudwatch_log_data_protection_policy" "this" {
  count = var.enable_data_protection ? 1 : 0

  log_group_name = module.log_group.log_group_this_name

  policy_document = jsonencode({
    Name    = "${var.log_group_name}-data-protection"
    Version = "2021-06-01"

    Statement = [
      {
        Sid            = "MaskPIIAndOTP"
        DataIdentifier = [
          "arn:aws:dataprotection::aws:data-identifier/EmailAddress",
          "arn:aws:dataprotection::aws:data-identifier/Address",
          "arn:aws:dataprotection::aws:data-identifier/AwsSecretKey",
          "arn:aws:dataprotection::aws:data-identifier/OpenSshPrivateKey",
          "arn:aws:dataprotection::aws:data-identifier/PgpPrivateKey",
          "arn:aws:dataprotection::aws:data-identifier/PkcsPrivateKey",
          "arn:aws:dataprotection::aws:data-identifier/PuttyPrivateKey",
        ]
        Operation = {
          Audit = {
            FindingsDestination = {}
          }
          Deidentify = {
            MaskConfig = {}
          }
        }
      },
      {
        Sid            = "MaskOTPCodes"
        DataIdentifier = []
        Operation = {
          Audit = {
            FindingsDestination = {}
          }
          Deidentify = {
            MaskConfig = {}
          }
        }
      }
    ]

    Configuration = {
      CustomDataIdentifiers = [
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
  })
}
