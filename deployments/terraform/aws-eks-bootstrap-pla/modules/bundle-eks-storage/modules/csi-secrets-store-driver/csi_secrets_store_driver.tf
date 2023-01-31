#
# (Unmanaged) Addon "Secrets Store CSI Driver"
#
# Common:         https://docs.aws.amazon.com/secretsmanager/latest/userguide/integrating_csi_driver.html
# Common:         https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html
# Helm Chart:         https://github.com/kubernetes-sigs/secrets-store-csi-driver/tree/v1.2.4/charts/secrets-store-csi-driver
# Helm Chart values:  https://github.com/kubernetes-sigs/secrets-store-csi-driver/blob/v1.2.4/charts/secrets-store-csi-driver/values.yaml
#

resource "helm_release" "main" {
  name      = "csi-secrets-store-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.2.4" # 2022-Sep-08

  set {
    name  = "fullnameOverride"
    value = "csi-secrets-store-driver" # If not set, pod name would be "csi-secrets-store-driver-secrets-store-csi-driver-RANDOM"
  }

  #
  # Secret Rotation
  # https://secrets-store-csi-driver.sigs.k8s.io/topics/secret-auto-rotation.html
  # https://github.com/aws/secrets-store-csi-driver-provider-aws#rotation
  #
  set {
    name  = "enableSecretRotation"
    value = "true"
  }
  set {
    name  = "rotationPollInterval"
    value = "3600s"
  }
}