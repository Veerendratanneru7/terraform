# ==============================================================================
# IAM RESOURCES FOR MFA
# Defines IAM roles, policies, and instance profiles for EC2 instances
# ==============================================================================

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mfa_instance" {
  statement {
    sid = "CloudWatchMetrics"
    actions = [
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }

  statement {
    sid = "CloudWatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:*:${local.account_id}:log-group:/smartvault/mfa/*"
    ]
  }

  statement {
    sid = "AutoScaling"
    actions = [
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeAutoScalingGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }

  statement {
    sid = "SSMParameters"
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:*:${local.account_id}:parameter/${local.env_id}/apersona/*"
    ]
  }

  statement {
    sid = "CloudFormationSignal"
    actions = [
      "cloudformation:SignalResource"
    ]
    resources = [
      "arn:aws:cloudformation:*:${local.account_id}:stack/smartvault-${local.env_id}-*/*"
    ]
  }
}

data "aws_iam_policy_document" "log_group_access_deny" {
  count = local.is_production ? 1 : 0

  statement {
    sid     = "DenyLogGroupAccess"
    effect  = "Deny"
    actions = ["logs:*"]
    resources = [
      module.cloudwatch_log_portal.log_group_arn,
      module.cloudwatch_log_webapps.log_group_arn,
      module.cloudwatch_log_callback.log_group_arn
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:PrincipalArn"
      values = concat(
        [
          "arn:aws:iam::${local.account_id}:role/smartvault-${local.env_id}-iam-role-mfa",
          "arn:aws:iam::${local.account_id}:instance-profile/smartvault-${local.env_id}-iam-instanceprofile-mfa",
          "arn:aws:iam::${local.account_id}:user/abhishek.pathak",
          "arn:aws:iam::${local.account_id}:user/corey.pon",
          "arn:aws:iam::${local.account_id}:user/manik.rajendra"
        ],
        [for user in var.restricted_users : "arn:aws:iam::${local.account_id}:user/${user}"]
      )
    }
  }
}

resource "aws_iam_role" "mfa" {
  name               = "smartvault-${local.env_id}-iam-role-mfa"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Name = "smartvault-${local.env_id}-iam-role-mfa"
  }
}

resource "aws_iam_role_policy" "mfa" {
  name   = "smartvault-${local.env_id}-iam-policy-mfa"
  role   = aws_iam_role.mfa.id
  policy = data.aws_iam_policy_document.mfa_instance.json
}

resource "aws_iam_instance_profile" "mfa" {
  name = "smartvault-${local.env_id}-iam-instanceprofile-mfa"
  role = aws_iam_role.mfa.name

  tags = {
    Name = "smartvault-${local.env_id}-iam-instanceprofile-mfa"
  }
}

resource "aws_iam_group_policy" "log_group_access_deny" {
  count = local.is_production ? 1 : 0

  name   = "MFACloudWatchLoggroupAccess"
  group  = "smartvault-iam-group-devops"
  policy = data.aws_iam_policy_document.log_group_access_deny[0].json
}
