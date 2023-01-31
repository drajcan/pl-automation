#
# (Unmanaged) Addon "CSI Secrets Store Provider AWS" - Requires the driver to be installed first
#
# Common:         https://github.com/aws/secrets-store-csi-driver-provider-aws
# See https://github.com/aws/eks-charts/tree/gh-pages to find the github tag for the chart!
# Helm Chart:         https://github.com/aws/eks-charts/tree/v0.0.95/stable/csi-secrets-store-provider-aws
# Helm Chart values:  https://github.com/aws/eks-charts/blob/v0.0.95/stable/csi-secrets-store-provider-aws/values.yaml
#
resource "helm_release" "main" {
  name      = "aws-csi-secrets-store-provider"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "csi-secrets-store-provider-aws"
  version    = "0.0.3" # 2022-Jun-03

  set {
    name  = "fullnameOverride"
    value = "aws-csi-secrets-store-provider"
  }

  # Do not install the Driver as we install it on our own
  set {
    name  = "secrets-store-csi-driver.install"
    value = false
  }
}