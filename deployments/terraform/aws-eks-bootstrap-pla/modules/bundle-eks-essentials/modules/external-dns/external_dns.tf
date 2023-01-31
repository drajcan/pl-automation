#
# (Unmanaged) Addon External DNS
# 
# Helm Chart:     https://artifacthub.io/packages/helm/bitnami/external-dns
# Helm Chart:     https://github.com/bitnami/charts/tree/master/bitnami/external-dns
# AWS/IAM Policy: https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-permissions

# 1. Create an IAM Role which can be used by a Kubernetes Service Account
# See https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-external-dns"
  service_accounts                    = ["kube-system/external-dns"]
  inline_policies = [<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
  ]
}

# 2. Deploy External-DNS via helm (v3)
resource "helm_release" "main" {
  depends_on = [module.iam_role]

  name      = "external-dns"
  namespace = "kube-system"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.5.6" # 2022-Jun-14

  #
  # Overall settings
  #
  set {
    name  = "image.registry"
    value = "registry.k8s.io" # New official image registry (since Mid of 2022) - https://github.com/kubernetes/k8s.io/wiki/New-Registry-url-for-Kubernetes-(registry.k8s.io)
  }
  set {
    name  = "image.repository"
    value = "external-dns/external-dns" # minimal image compared to Bitnami
  }
  set {
    name  = "image.tag"
    value = "v0.12.2" # 2022-Jul-27
  }
  set {
    name  = "txtOwnerId"
    value = var.eks_cluster_name
  }
  set {
    name  = "policy"
    value = "sync"
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }
  set {
    name  = "resources.limits.memory"
    value = "50Mi"
  }
  set {
    name  = "resources.requests.cpu"
    value = "5m"
  }
  set {
    name  = "resources.requests.memory"
    value = "20Mi"
  }
  set {
    name  = "replicaCount" # one replica is sufficient for operations
    value = "1"
  }
  set {
    name  = "podDisruptionBudget.maxUnavailable"
    value = "1"
  }

  #
  # AWS specific settings
  #
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "aws.region"
    value = var.region
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_role.this_role_arn
  }

  values = [<<EOF
metrics:
  enabled: true
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
    prometheus.io/port: "7979"

service:
  enabled: false

containerSecurityContext:
  privileged: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 65534
  runAsGroup: 65534

podSecurityContext:
  enabled: true
  runAsUser: 65534
  runAsGroup: 65534
  fsGroup: 65534
  seccompProfile:
    type: RuntimeDefault

EOF
  ]

}