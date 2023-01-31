#
# (Unmanaged) Addon "Calico"
#
# Common:         https://docs.aws.amazon.com/eks/latest/userguide/calico.html
#                 https://github.com/projectcalico/calico
# Helm Chart:     https://github.com/projectcalico/calico/tree/master/charts/tigera-operator
#                 https://github.com/projectcalico/calico/blob/master/charts/tigera-operator/values.yaml
#                 https://github.com/projectcalico/calico/tree/master/charts/tigera-operator#values-reference
#
# Note: After installation manually modify FelixConfiguration
#
# spec:
#   logFilePath: none
#   logSeverityScreen: Error
#   logSeveritySys: none
#
module "namespace" {
  source = "../../../kubernetes_namespace"
  name   = "tigera-operator"
}

# See https://github.com/tigera/operator/issues/2031
# In case tigera-operator does not uninstall and namespace "calico-system" will not be deleted, run this
# kubectl patch -n calico-system ServiceAccount/calico-node --type json --patch='[{"op":"remove","path":"/metadata/finalizers"}]'

resource "helm_release" "main" {
  count      = 0
  depends_on = [module.namespace]

  name      = "calico"
  namespace = "tigera-operator"

  repository = "https://projectcalico.docs.tigera.io/charts"
  chart      = "tigera-operator"
  version    = "v3.24.1" # 2022-Aug-26

  values = [<<EOF
# Configures general installation parameters for Calico. Schema is based
# on the operator.tigera.io/Installation API documented
# here: https://projectcalico.docs.tigera.io/reference/installation/api#operator.tigera.io/v1.InstallationSpec
installation:
  enabled: true
  
  #
  # Please Note: These values were taken from a fresh installation where these values where auto-detected.
  # See https://projectcalico.docs.tigera.io/security/non-privileged
  #
  calicoNetwork:
    bgp: Disabled
    linuxDataplane: Iptables
  cni:
    ipam:
      type: AmazonVPC
    type: AmazonVPC
  controlPlaneReplicas: 2
  flexVolumePath: /usr/libexec/kubernetes/kubelet-plugins/volume/exec/
  imagePullSecrets: []
  kubernetesProvider: EKS
  nodeUpdateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  # Run Calico-Node non-privileged, also see issue https://github.com/projectcalico/calico/issues/5348
  nonPrivileged: Enabled
  variant: Calico

# Configures general installation parameters for Calico. Schema is based
# on the operator.tigera.io/Installation API documented
# here: https://projectcalico.docs.tigera.io/reference/installation/api#operator.tigera.io/v1.APIServerSpec
apiServer:
  enabled: false

# Resources for the tigera/operator pod itself.
# By default, no resource requests or limits are specified.
resources:
  limits:
    cpu: 50m
    memory: 128Mi
  requests:
    cpu: 5m
    memory: 128Mi

EOF
  ]
}
