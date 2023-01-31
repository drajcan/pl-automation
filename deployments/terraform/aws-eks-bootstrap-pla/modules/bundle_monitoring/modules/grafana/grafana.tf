#
# (Unmanaged) Addon "Grafana"
#
# Common:         https://grafana.com/oss/grafana/
#                 https://github.com/grafana/grafana
# 
# Helm Chart:         https://github.com/grafana/helm-charts/tree/grafana-6.25.1/charts/grafana
# Helm Chart values:  https://github.com/grafana/helm-charts/blob/grafana-6.25.1/charts/grafana/values.yaml
#

# https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-grafana"
  service_accounts                    = ["grafana/grafana"]
  inline_policies = [<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowReadingMetricsFromCloudWatch",
      "Effect": "Allow",
      "Action": [
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetInsightRuleReport"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowReadingLogsFromCloudWatch",
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups",
        "logs:GetLogGroupFields",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults",
        "logs:GetLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowReadingTagsInstancesRegionsFromEC2",
      "Effect": "Allow",
      "Action": ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"],
      "Resource": "*"
    },
    {
      "Sid": "AllowReadingResourcesForTags",
      "Effect": "Allow",
      "Action": "tag:GetResources",
      "Resource": "*"
    }
  ]
}
EOF
  ]
}

module "namespace" {
  source = "../../../kubernetes_namespace"
  name   = "grafana"
}

# Note: We always create the Secret for OIDC even if it is not enabled.
# Otherwise we may get a race condition on terraform destroy if OIDC is enabled and the secret is delete before the helm release.
# In this case the removal of the helm release get stuck as the Load Balancer Controller complains about the missing secret
# "Failed build model due to ingress: grafana/grafana: secrets "grafana-ingress-oidc" not found"
resource "kubernetes_secret_v1" "ingress_oidc" {
  depends_on = [module.namespace]

  metadata {
    name      = "grafana-ingress-oidc"
    namespace = "grafana"
    annotations = {
      "description" = "OIDC Client ID and Client Secret for OIDC Auth at AWS ALB for Grafana."
    }
  }

  data = {
    # Note: Logical binary operators don't short-circuit - see https://github.com/hashicorp/terraform/issues/24128
    clientID     = var.ingress_enabled ? (var.ingress_settings.oidc_enabled ? var.ingress_settings.oidc_client_id : "") : ""
    clientSecret = var.ingress_enabled ? (var.ingress_settings.oidc_enabled ? var.ingress_oidc_client_secret : "") : ""
  }
  type = "Opaque"
}

locals {
  host_name = var.ingress_enabled ? var.ingress_settings.host_name : "localhost"

  ingress_group_name = var.ingress_enabled ? var.ingress_settings.ingress_group : ""
  # Note: Logical binary operators don't short-circuit - see https://github.com/hashicorp/terraform/issues/24128
  ingress_annotation_auth_type = var.ingress_enabled ? (var.ingress_settings.oidc_enabled ? "oidc" : "none") : "none"
  # Must be JSON (empty or not), otherwise error
  # Failed build model due to ingress: namespace/name: failed to parse json annotation, alb.ingress.kubernetes.io/auth-idp-oidc: : unexpected end of JSON input
  ingress_annotation_auth_idp_oidc = var.ingress_enabled ? (var.ingress_settings.oidc_enabled ? jsonencode(
    {
      "issuer"                = var.ingress_settings.oidc_issuer
      "authorizationEndpoint" = var.ingress_settings.oidc_authorization_endpoint
      "tokenEndpoint"         = var.ingress_settings.oidc_token_endpoint
      "userInfoEndpoint"      = var.ingress_settings.oidc_user_info_endpoint
      # pragma: allowlist nextline secret
      "secretName" = "grafana-ingress-oidc"
    }
  ) : "{}") : "{}"
}

resource "helm_release" "main" {
  depends_on = [
    module.namespace,
    module.iam_role,
    kubernetes_secret_v1.ingress_oidc
  ]
  name      = "grafana"
  namespace = "grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.25.1"

  values = [
    templatefile("${path.module}/templates/helm_values.yaml",
      {
        role_arn  = module.iam_role.this_role_arn,
        host_name = local.host_name,

        ingress_enabled                  = var.ingress_enabled,
        ingress_group_name               = local.ingress_group_name,
        ingress_annotation_auth_type     = local.ingress_annotation_auth_type,
        ingress_annotation_auth_idp_oidc = local.ingress_annotation_auth_idp_oidc,

        azuread_auth_enabled       = var.azuread_auth_enabled,
        azuread_auth_settings      = var.azuread_auth_settings,
        azuread_auth_client_secret = var.azuread_auth_client_secret
      }
    )
  ]
}