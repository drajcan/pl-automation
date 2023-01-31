#
# EKS Add-On CSI Driver for EFS (Elastic File System = NFS)
#
# Common: https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
#
# 1. IAM Role
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-efs-csi-controller"
  service_accounts                    = ["kube-system/efs-csi-controller-sa"]
  # from https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/helm-chart-aws-efs-csi-driver-2.3.2/docs/iam-policy-example.json
  inline_policies = [<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeMountTargets",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
EOF
  ]
}

# https://github.com/kubernetes-sigs/aws-efs-csi-driver/tree/helm-chart-aws-efs-csi-driver-2.3.2/charts/aws-efs-csi-driver
resource "helm_release" "main" {
  depends_on = [module.iam_role]

  name      = "aws-efs-csi-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  version    = "2.3.2" # 2022-Nov-10

  values = [<<EOF
# Controller is a deployment and has 2 replicas by default
controller:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${module.iam_role.this_role_arn}
  affinity:
    # Do not run controllers on the same host
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - efs-csi-controller
          topologyKey: kubernetes.io/hostname
        weight: 100
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 10m
      memory: 128Mi

# node is a daemonset
node:
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 10m
      memory: 40Mi

# Sidecar containers
sidecars:
  livenessProbe:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
  nodeDriverRegistrar:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
  csiProvisioner:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi

EOF
  ]
}
