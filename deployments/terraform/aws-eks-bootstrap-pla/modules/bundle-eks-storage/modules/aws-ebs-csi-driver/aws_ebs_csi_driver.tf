#
# EKS Add-On CSI Driver
# We DO NOT USE the managed EKS Add-On as it is buggy as of 2022-May-27 and is using deprecated images that do not work with the CRDs in stable version!
#
# Common:  https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html#csi-iam-role
# AWS/IAM: https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
#
# 1. IAM Role
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-ebs-csi-controller"
  service_accounts                    = ["kube-system/ebs-csi-controller-sa"]
  policy_arns                         = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

# https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/charts/aws-ebs-csi-driver/CHANGELOG.md#v2110
resource "null_resource" "prerequisites" {
  provisioner "local-exec" {
    command = <<EOF
    kubectl --kubeconfig ${var.kubeconfig_filename} --ignore-not-found=true delete csidriver ebs.csi.aws.com
EOF
  }
}
resource "helm_release" "main" {
  depends_on = [
    module.iam_role,
    null_resource.prerequisites
  ]

  name      = "aws-ebs-csi-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.11.1" # 2022-Sep-16

  values = [<<EOF
# Controller is a deployment and has 2 replicas by default
controller:
  k8sTagClusterId: ${var.eks_cluster_name}
  region: ${var.region}
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
              - ebs-csi-controller
          topologyKey: kubernetes.io/hostname
        weight: 100
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 1
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 10m
      memory: 128Mi
  securityContext:
    # changed UIDs from 1000 to 65534:
    runAsNonRoot: true
    runAsUser: 65534
    runAsGroup: 65534
    fsGroup: 65534
    # added to securityContext:
    seccompProfile:
      type: RuntimeDefault
  # securityContext on the controller container (see sidecars for securityContext on sidecar containers)
  containerSecurityContext:
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    # added to securityContext:
    privileged: false
    runAsNonRoot: true
    capabilities:
      drop:
      - ALL

# node is a daemonset
node:
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
    requests:
      cpu: 10m
      memory: 40Mi
  # securityContext on the node pod
  securityContext:
    # The node pod must be run as root to bind to the registration/driver sockets
    runAsNonRoot: false
    runAsUser: 0
    runAsGroup: 0
    fsGroup: 0
    # added to securityContext:
    seccompProfile:
      type: RuntimeDefault
  # securityContext on the node container (see sidecars for securityContext on sidecar containers)
  containerSecurityContext:
    readOnlyRootFilesystem: true
    privileged: true
    # added to securityContext:
    capabilities:
      drop:
      - ALL

# Sidecar containers
sidecars:
  # csi-provisioner used by controller
  provisioner:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      # added to securityContext:
      privileged: false
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
  # csi-attacher used by controller
  attacher:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      # added to securityContext:
      privileged: false
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
  # csi-snapshotter used by controller
  snapshotter:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      # added to securityContext:
      privileged: false
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
  # livenessProbe used by controller AND node
  livenessProbe:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      # added to securityContext:
      privileged: false
      # do not set runAsNonRoot to true as this container is used also used in node pod which requires root
      # runAsNonRoot: true
      capabilities:
        drop:
        - ALL
  # csi-resizer used by controller
  resizer:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      # added to securityContext:
      privileged: false
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
  # nodeDriverRegistrar used by node and requires to run as root
  nodeDriverRegistrar:
    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 10m
        memory: 40Mi
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      # added to securityContext:
      privileged: false
      # do not set runAsNonRoot to true as this container is used also used in node pod which requires root
      # runAsNonRoot: true
      capabilities:
        drop:
        - ALL

EOF
  ]
}
