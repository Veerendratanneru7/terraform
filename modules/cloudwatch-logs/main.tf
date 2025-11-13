resource "aws_cloudwatch_log_group" "portal" {
  name              = "/smartvault/mfa/portal"
  retention_in_days = 365

  tags = {
    Name = "smartvault-mfa-portal-logs"
  }
}

resource "aws_cloudwatch_log_data_protection_policy" "portal" {
  log_group_name = aws_cloudwatch_log_group.portal.name

  policy_document = jsonencode({
    Name        = "portal-data-protection-policy"
    Description = "Log group data protection policy for masking OTP in portal logs"
    Version     = "2021-06-01"

    Statement = [
      {
        Sid = "audit-policy"
        DataIdentifier = [
          "Otp", "otp", "OTP_SENT", "o", "verificationCode",
          "About-to-send-OTP", "catalina_otp", "entered-OTP",
          "passcodeSmartvault", "messagePasscode"
        ]
        Operation = {
          Audit = {
            FindingsDestination = {}
          }
        }
      },
      {
        Sid = "redact-policy"
        DataIdentifier = [
          "Otp", "otp", "OTP_SENT", "o", "verificationCode",
          "About-to-send-OTP", "catalina_otp", "entered-OTP",
          "passcodeSmartvault", "messagePasscode"
        ]
        Operation = {
          Deidentify = {
            MaskConfig = {}
          }
        }
      }
    ]

    Configuration = {
      CustomDataIdentifier = [
        { Name = "Otp", Regex = "Otp:[0-9]{6}" },
        { Name = "otp", Regex = "otp=[0-9]{6}" },
        { Name = "OTP_SENT", Regex = "OTP_SENT=[0-9]{6}" },
        { Name = "o", Regex = "o=[0-9]{6}" },
        { Name = "verificationCode", Regex = "verificationCode=[0-9]{6}" },
        { Name = "About-to-send-OTP", Regex = "About to send OTP:[0-9]{6}" },
        { Name = "catalina_otp", Regex = "&nbsp;[0-9]{6}&" },
        { Name = "entered-OTP", Regex = "entered OTP:[0-9]{6}" },
        {
          Name  = "passcodeSmartvault"
          Regex = "Your one time passcode for Smartvault is, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, Again, the passcode is [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}"
        },
        { Name = "messagePasscode", Regex = "message:[0-9]{6}" }
      ]
    }
  })
}

resource "aws_cloudwatch_log_group" "webapps" {
  name              = "/smartvault/mfa/webapps"
  retention_in_days = 365

  tags = {
    Name = "smartvault-mfa-webapps-logs"
  }
}

resource "aws_cloudwatch_log_data_protection_policy" "webapps" {
  log_group_name = aws_cloudwatch_log_group.webapps.name

  policy_document = jsonencode({
    Name        = "webapps-data-protection-policy"
    Description = "Log group data protection policy for masking OTP in webapps logs"
    Version     = "2021-06-01"

    Statement = [
      {
        Sid = "audit-policy"
        DataIdentifier = [
          "Otp", "otp", "OTP_SENT", "o", "verificationCode",
          "About-to-send-OTP", "catalina_otp", "entered-OTP",
          "passcodeSmartvault", "messagePasscode"
        ]
        Operation = {
          Audit = {
            FindingsDestination = {}
          }
        }
      },
      {
        Sid = "redact-policy"
        DataIdentifier = [
          "Otp", "otp", "OTP_SENT", "o", "verificationCode",
          "About-to-send-OTP", "catalina_otp", "entered-OTP",
          "passcodeSmartvault", "messagePasscode"
        ]
        Operation = {
          Deidentify = {
            MaskConfig = {}
          }
        }
      }
    ]

    Configuration = {
      CustomDataIdentifier = [
        { Name = "Otp", Regex = "Otp:[0-9]{6}" },
        { Name = "otp", Regex = "otp=[0-9]{6}" },
        { Name = "OTP_SENT", Regex = "OTP_SENT=[0-9]{6}" },
        { Name = "o", Regex = "o=[0-9]{6}" },
        { Name = "verificationCode", Regex = "verificationCode=[0-9]{6}" },
        { Name = "About-to-send-OTP", Regex = "About to send OTP:[0-9]{6}" },
        { Name = "catalina_otp", Regex = "&nbsp;[0-9]{6}&" },
        { Name = "entered-OTP", Regex = "entered OTP:[0-9]{6}" },
        {
          Name  = "passcodeSmartvault"
          Regex = "Your one time passcode for Smartvault is, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, Again, the passcode is [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}"
        },
        { Name = "messagePasscode", Regex = "message:[0-9]{6}" }
      ]
    }
  })
}

resource "aws_cloudwatch_log_group" "callback" {
  name              = "/smartvault/mfa/callback"
  retention_in_days = 365

  tags = {
    Name = "smartvault-mfa-callback-logs"
  }
}

resource "aws_cloudwatch_log_data_protection_policy" "callback" {
  log_group_name = aws_cloudwatch_log_group.callback.name

  policy_document = jsonencode({
    Name        = "callback-data-protection-policy"
    Description = "Log group data protection policy for masking OTP in callback logs"
    Version     = "2021-06-01"

    Statement = [
      {
        Sid = "audit-policy"
        DataIdentifier = [
          "Otp", "otp", "OTP_SENT", "o", "verificationCode",
          "About-to-send-OTP", "catalina_otp", "entered-OTP",
          "passcodeSmartvault", "messagePasscode"
        ]
        Operation = {
          Audit = {
            FindingsDestination = {}
          }
        }
      },
      {
        Sid = "redact-policy"
        DataIdentifier = [
          "Otp", "otp", "OTP_SENT", "o", "verificationCode",
          "About-to-send-OTP", "catalina_otp", "entered-OTP",
          "passcodeSmartvault", "messagePasscode"
        ]
        Operation = {
          Deidentify = {
            MaskConfig = {}
          }
        }
      }
    ]

    Configuration = {
      CustomDataIdentifier = [
        { Name = "Otp", Regex = "Otp:[0-9]{6}" },
        { Name = "otp", Regex = "otp=[0-9]{6}" },
        { Name = "OTP_SENT", Regex = "OTP_SENT=[0-9]{6}" },
        { Name = "o", Regex = "o=[0-9]{6}" },
        { Name = "verificationCode", Regex = "verificationCode=[0-9]{6}" },
        { Name = "About-to-send-OTP", Regex = "About to send OTP:[0-9]{6}" },
        { Name = "catalina_otp", Regex = "&nbsp;[0-9]{6}&" },
        { Name = "entered-OTP", Regex = "entered OTP:[0-9]{6}" },
        {
          Name  = "passcodeSmartvault"
          Regex = "Your one time passcode for Smartvault is, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, Again, the passcode is [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}, [0-9]{1}"
        },
        { Name = "messagePasscode", Regex = "message:[0-9]{6}" }
      ]
    }
  })
}
