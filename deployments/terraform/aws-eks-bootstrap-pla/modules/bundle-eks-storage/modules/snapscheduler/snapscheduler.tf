#
# (Unmanaged) Addon "snapscheduler"
#
# Common:         https://backube.github.io/snapscheduler/install.html
#                 https://github.com/backube/snapscheduler
# 
# Helm Chart:         https://github.com/backube/snapscheduler/tree/v3.1.0/helm/snapscheduler
# Helm Chart values:  https://github.com/backube/snapscheduler/blob/v3.1.0/helm/snapscheduler/values.yaml
#
module "namespace" {
  source = "../../../kubernetes_namespace"
  name   = "snapscheduler"
}

resource "helm_release" "main" {
  depends_on = [module.namespace]

  name      = "snapscheduler"
  namespace = "snapscheduler"

  repository = "https://backube.github.io/helm-charts"
  chart      = "snapscheduler"
  version    = "3.1.0"

  values = [<<EOF
replicaCount: 2

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 10m
    memory: 128Mi

securityContext:
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
  runAsUser: 65534
  runAsGroup: 65534
  fsGroup: 65534
  seccompProfile:
    type: RuntimeDefault
EOF
  ]
}