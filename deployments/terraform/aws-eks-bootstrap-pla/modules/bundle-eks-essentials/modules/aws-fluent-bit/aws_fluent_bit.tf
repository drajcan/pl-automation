#
# Notes: SecurityContext cannot be set as of 2022-July-05
#

#
# (Unmanaged) Addon "Fluent-Bit"
#
# Common:         https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch
# Common:         https://github.com/aws/aws-for-fluent-bit
# Helm Chart:     https://github.com/aws/eks-charts/tree/master/stable/aws-for-fluent-bit
# AWS/IAM Policy KMS: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html and https://docs.bridgecrew.io/docs/logging_21
# AWS/IAM Policy Pod: https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit#permissions (note: we create LogGroup on our own)
#

# KMS Key for encrypting Cloudwatch Logs
resource "aws_kms_key" "main" {
  description = "EKS Cluster ${var.eks_cluster_name} Secret Encryption Key for Container Logs"
  # Also see https://github.com/hashicorp/terraform-provider-aws/issues/20588
  # Use string literal "true" instead of boolean true, otherwise
  # error waiting for KMS Key (ID) tag propagation timeout while waiting for state to become 'TRUE' (last state: 'FALSE', timeout: 5m0s)

  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow direct access to key metadata to the account"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Cloudwatch service to access key"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/eks/${var.eks_cluster_name}/containers"
          }
        }
      }
    ]
  })
}
resource "aws_kms_alias" "main" {
  name          = "alias/eks/${var.eks_cluster_name}/containers"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/eks/${var.eks_cluster_name}/containers"
  kms_key_id        = aws_kms_key.main.arn
  retention_in_days = 30
}

# 1. Create an IAM Role which can be used by a Kubernetes Service Account
# See https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-fluent_bit"
  service_accounts                    = ["kube-system/fluent-bit"]
  inline_policies = [<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid" : "AccessToCloudwatch",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": [
              "${aws_cloudwatch_log_group.main.arn}",
              "${aws_cloudwatch_log_group.main.arn}:*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
  ]
}

# 2. Deploy via helm (v3)
# https://github.com/aws/eks-charts/blob/master/stable/aws-for-fluent-bit/Chart.yaml
resource "helm_release" "main" {
  depends_on = [module.iam_role]

  name      = "aws-for-fluent-bit"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.21" # 2022-Sep-08

  set {
    name  = "image.tag"
    value = "2.28.1" # 2022-Sep-13
  }
  set {
    name  = "serviceAccount.name"
    value = "fluent-bit"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_role.this_role_arn
  }
  set {
    name  = "cloudWatch.enabled"
    value = "false"
  }
  set {
    name  = "firehose.enabled"
    value = "false"
  }
  set {
    name  = "kinesis.enabled"
    value = "false"
  }
  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }

  # For exposing Prometheus metrics, see https://docs.fluentbit.io/manual/administration/monitoring
  values = [<<EOF
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/api/v1/metrics/prometheus"
  prometheus.io/port: "9545"

service:
  extraService: |
    HTTP_Server  On
    HTTP_Listen  0.0.0.0
    HTTP_PORT    9545

input:
  tag: "kube.*"
  path: "/var/log/containers/*.log"
  db: "/var/log/flb_kube.db"
  parser: docker
  dockerMode: "On"
  memBufLimit: 5MB
  skipLongLines: "On"
  refreshInterval: 10

filter:
  match: "kube.*"
  kubeURL: "https://kubernetes.default.svc.cluster.local:443"
  mergeLog: "On"
  mergeLogKey: "data"
  keepLog: "On"
  k8sLoggingParser: "On"
  k8sLoggingExclude: "On"

# https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch
additionalOutputs: |
  [OUTPUT]
      Name cloudwatch_logs
      Match kube.*
      region ${var.region}
      log_group_name ${aws_cloudwatch_log_group.main.name}
      log_stream_prefix from-fluent-bit-
      auto_create_group false
EOF
  ]
}