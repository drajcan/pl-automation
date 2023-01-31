#
# (Unmanaged) Addon "Cluster Autoscaler"
#
# Common:         https://aws.github.io/aws-eks-best-practices/cluster-autoscaling/
# Common:         https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
# Helm Chart:     https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-chart-9.21.0/charts/cluster-autoscaler
# AWS/IAM Policy: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md
#

# 1. Create an IAM Role which can be used by a Kubernetes Service Account
# See https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-cluster-autoscaler"
  service_accounts                    = ["kube-system/cluster-autoscaler"]
  inline_policies = [<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
  ]
}

# 2. Deploy via helm
resource "helm_release" "main" {
  depends_on = [module.iam_role]

  name      = "cluster-autoscaler"
  namespace = "kube-system"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.21.0" # 2022-Sep-05

  set {
    name  = "fullnameOverride"
    value = "cluster-autoscaler" # If not set, pod name would be "cluster-autoscaler-aws-cluster-autoscaler-RANDOM"
  }
  set {
    name  = "image.tag"
    value = "v1.25.0" # 2022-Sep-06
  }
  set {
    name  = "extraArgs.logtostderr"
    value = "true"
  }
  set {
    name  = "extraArgs.stderrthreshold"
    value = "info"
  }
  set {
    name  = "extraArgs.v"
    value = "4"
  }
  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }
  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }
  set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = "false"
  }
  set {
    name  = "extraArgs.unremovable-node-recheck-timeout"
    value = "1m"
  }



  # https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html
  # set {
  #   name  = "podAnnotations.cluster-autoscaler\\.kubernetes.io/safe-to-evict"
  #   value = "false"
  # }

  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }
  set {
    name  = "resources.limits.memory"
    value = "500Mi"
  }
  set {
    name  = "resources.requests.cpu"
    value = "25m"
  }
  set {
    name  = "resources.requests.memory"
    value = "500Mi"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = var.eks_cluster_name
  }

  #
  # AWS specific settings
  #
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_role.this_role_arn
  }
  set {
    name  = "service.create"
    value = "false"
  }

  values = [<<EOF
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
  prometheus.io/port: "8085"

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

securityContext: 
  runAsUser: 65534
  runAsGroup: 65534
  fsGroup: 65534
  seccompProfile:
    type: RuntimeDefault

replicaCount: 2

affinity:
  # Do not run on the same host
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - aws-cluster-autoscaler
        topologyKey: kubernetes.io/hostname
      weight: 100

EOF
  ]
}