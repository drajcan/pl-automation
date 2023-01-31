#
# (Unmanaged) Addon "Metrics-Server" on AWS EKS
#
# https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
# https://github.com/kubernetes-sigs/metrics-server/tree/metrics-server-helm-chart-3.8.2/charts/metrics-server
#

resource "helm_release" "main" {
  name      = "metrics-server"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.8.2" # 2022-Feb-23

  set {
    name  = "image.tag"
    value = "v0.6.1" # 2022-Feb-09
  }
  values = [<<EOF
replicas: 2

affinity:
  # Do not run on the same host
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/instance
            operator: In
            values:
            - ebs-csi-controller
        topologyKey: kubernetes.io/hostname
      weight: 100

podSecurityContext:
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

securityContext:
  privileged: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000

resources:
  limits:
    cpu: 50m
    memory: 100Mi
  requests:
    cpu: 5m
    memory: 100Mi

EOF
  ]

}