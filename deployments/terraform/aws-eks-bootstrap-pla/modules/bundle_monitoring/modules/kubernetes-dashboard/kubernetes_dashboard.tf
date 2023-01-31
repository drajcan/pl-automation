#
# (Unmanaged) Addon "Kubernetes Dashboard"
#
# Common:         https://github.com/kubernetes/dashboard
# Helm Chart:     https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
# Helm Chart source: https://github.com/kubernetes/dashboard/tree/master/aio/deploy/helm-chart/kubernetes-dashboard
# Command line args: https://github.com/kubernetes/dashboard/blob/master/docs/common/dashboard-arguments.md
#
module "namespace" {
  source = "../../../kubernetes_namespace"
  name   = "kubernetes-dashboard"
}

# Note: We always create the Secret for OIDC even if it is not enabled.
# Otherwise we may get a race condition on terraform destroy if OIDC is enabled and the secret is delete before the helm release.
# In this case the removal of the helm release get stuck as the Load Balancer Controller complains about the missing secret
# "Failed build model due to ingress: grafana/grafana: secrets "grafana-ingress-oidc" not found"
resource "kubernetes_secret_v1" "ingress_oidc" {
  depends_on = [module.namespace]

  metadata {
    name      = "kubernetes-dashboard-ingress-oidc"
    namespace = "kubernetes-dashboard"
    annotations = {
      "description" = "OIDC Client ID and Client Secret for OIDC Auth by AWS ALB for Kubernetes Dashboard."
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
  ingress_group_name = var.ingress_enabled ? var.ingress_settings.ingress_group : ""
  host_name          = var.ingress_enabled ? var.ingress_settings.host_name : ""
  # Note: Logical binary operators don't short-circuit - see https://github.com/hashicorp/terraform/issues/24128
  ingress_annotation_auth_type = var.ingress_enabled ? (var.ingress_settings.oidc_enabled ? "oidc" : "none") : "none"
  # Must be JSON (empty or not), otherwise error
  # Failed build model due to ingress: namespace/name: failed to parse json annotation, alb.ingress.kubernetes.io/auth-idp-oidc: : unexpected end of JSON input
  # Note: Logical binary operators don't short-circuit - see https://github.com/hashicorp/terraform/issues/24128
  ingress_annotation_auth_idp_oidc = var.ingress_enabled ? (var.ingress_settings.oidc_enabled ? jsonencode(
    {
      "issuer"                = var.ingress_settings.oidc_issuer
      "authorizationEndpoint" = var.ingress_settings.oidc_authorization_endpoint
      "tokenEndpoint"         = var.ingress_settings.oidc_token_endpoint
      "userInfoEndpoint"      = var.ingress_settings.oidc_user_info_endpoint
      # pragma: allowlist nextline secret
      "secretName" = "kubernetes-dashboard-ingress-oidc"
    }
  ) : "{}") : "{}"
}

resource "helm_release" "main" {
  depends_on = [
    module.namespace,
    kubernetes_secret_v1.ingress_oidc
  ]

  name      = "kubernetes-dashboard"
  namespace = "kubernetes-dashboard"

  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
  version    = "5.10.0" # 2022-Aug-24 https://github.com/kubernetes/dashboard/tree/ff56d00382e3c22bf5688c1c7f66c47324ca30e8

  values = [<<EOF
image:
  tag: v2.7.0  # 2022-Sep-16

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
            - kubernetes-dashboard
        topologyKey: kubernetes.io/hostname
      weight: 100

protocolHttp: true

extraArgs:
  - --enable-skip-login
  - --enable-insecure-login
  - --system-banner="Welcome to Kubernetes"

securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 2001
  seccompProfile:
    type: RuntimeDefault

containerSecurityContext:
  privileged: false
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsUser: 1001
  runAsGroup: 2001
  capabilities:
    drop:
      - ALL

rbac:
  clusterReadOnlyRole: true

ingress:
  enabled: ${var.ingress_enabled}

  # Let AWS LB Controller handle the ingress
  className: alb
  hosts:
    - "${local.host_name}"
  
  paths:
    - "/*"

  # For full list of annotations for AWS LB Controller, see https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/
  annotations:
    # The name of the ALB group, can be used to configure a single ALB by multiple ingress objects
    alb.ingress.kubernetes.io/group.name: ${local.ingress_group_name}
    # Specifies the HTTP path when performing health check on targets.
    alb.ingress.kubernetes.io/healthcheck-path: /
    # Specifies the port used when performing health check on targets.
    alb.ingress.kubernetes.io/healthcheck-port: traffic-port
    # Specifies the HTTP status code that should be expected when doing health checks against the specified health check path.
    alb.ingress.kubernetes.io/success-codes: "200"
    # Listen on HTTPS protocol at port 443 at the ALB
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    # Use target type IP which is the case if the service type is ClusterIP
    alb.ingress.kubernetes.io/target-type: ip

    #
    # OIDC
    #
    # pragma: allowlist nextline secret
    alb.ingress.kubernetes.io/auth-idp-oidc: '${local.ingress_annotation_auth_idp_oidc}'
    alb.ingress.kubernetes.io/auth-on-unauthenticated-request: authenticate
    alb.ingress.kubernetes.io/auth-scope: openid
    alb.ingress.kubernetes.io/auth-session-cookie: AWSELBAuthSessionCookie
    alb.ingress.kubernetes.io/auth-session-timeout: "3600"
    alb.ingress.kubernetes.io/auth-type: ${local.ingress_annotation_auth_type}
EOF
  ]
}