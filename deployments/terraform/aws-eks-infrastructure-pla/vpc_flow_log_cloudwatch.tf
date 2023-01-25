#
# Activates flow logs in VPC to Cloudwatch
#

# KMS Key for encrypting CloudWatch Log Group
# See https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html
data "aws_iam_policy_document" "vpc_flow_log_cloudwatch_kms_key" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0


  #checkov:skip=CKV_AWS_109:Ensure IAM policies does not allow permissions management / resource exposure without constraints
  #checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints
  statement {
    sid       = "AllowForOwnerAccount"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowForCloudwatch"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
  }
}
resource "aws_kms_key" "vpc_flow_log_cloudwatch" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0

  description             = "VPC Flow Log ${module.vpc.name} Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.vpc_flow_log_cloudwatch_kms_key[0].json
}
resource "aws_kms_alias" "vpc_flow_log_cloudwatch" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0

  name          = "alias/vpc/${module.vpc.name}"
  target_key_id = aws_kms_key.vpc_flow_log_cloudwatch[0].key_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log_cloudwatch" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0

  name              = "/vpc/${module.vpc.name}"
  retention_in_days = var.vpc_flow_log_cloudwatch_retention_in_days
  kms_key_id        = aws_kms_key.vpc_flow_log_cloudwatch[0].arn
}

resource "aws_flow_log" "vpc_flow_log_cloudwatch" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0

  iam_role_arn    = aws_iam_role.vpc_flow_log_cloudwatch[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_cloudwatch[0].arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
  tags            = { Name = "CloudWatch" }
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch_assume_role_policy" {
  statement {
    sid = "AllowVPCFlowLogToAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0

  name               = "${module.vpc.name}-cw-flow-log"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_cloudwatch_assume_role_policy.json
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch_role_policy" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0

  #checkov:skip=CKV_AWS_111:Ensure IAM policies does not allow write access without constraints
  statement {
    sid    = "AllowWriteToCloudwatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "vpc_flow_log_cloudwatch" {
  count = var.vpc_enable_flow_log_cloudwatch ? 1 : 0
  name  = "write-to-cloudwatch"
  role  = aws_iam_role.vpc_flow_log_cloudwatch[0].id

  policy = data.aws_iam_policy_document.vpc_flow_log_cloudwatch_role_policy[0].json
}