#
# Default settings for ingress class alb and groupname default
# Redirects from HTTP at port 80 to HTTPS at 443
#

# Manual sleep before default ingress(es) will be created as the webhook for verifying the ingress may not be ready
# Error: Failed to create Ingress 'kube-system/alb-bootstrapping-settings' because: Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/validate-networking-v1-ingress?timeout=10s": dial tcp 10.0.24.68:9443
resource "time_sleep" "wait" {
  create_duration = "20s"
}

resource "kubernetes_ingress_v1" "main" {
  depends_on = [time_sleep.wait]
  for_each   = var.ingress_groups

  metadata {
    name      = "alb-${each.key}-settings"
    namespace = "kube-system"
    annotations = {
      "description"                                          = "Default setting of ingress group ${each.key} for ingress class alb"
      "alb.ingress.kubernetes.io/certificate-arn"            = each.value.certificate_arn
      "alb.ingress.kubernetes.io/load-balancer-name"         = "${var.eks_cluster_name}-${each.key}"
      "alb.ingress.kubernetes.io/group.name"                 = each.key
      "alb.ingress.kubernetes.io/listen-ports"               = "[{\"HTTP\": 80},{\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/load-balancer-attributes"   = "access_logs.s3.enabled=${each.value.s3_logging_enabled},access_logs.s3.bucket=${each.value.s3_logging_bucket_name},access_logs.s3.prefix=${each.value.s3_logging_prefix},idle_timeout.timeout_seconds=${each.value.idle_timeout_seconds},deletion_protection.enabled=${each.value.deletion_protection_enabled}"
      "alb.ingress.kubernetes.io/scheme"                     = "internet-facing"
      "alb.ingress.kubernetes.io/ssl-policy"                 = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      "alb.ingress.kubernetes.io/ssl-redirect"               = "443"
      "alb.ingress.kubernetes.io/actions.response-404"       = "{\"type\":\"fixed-response\",\"fixedResponseConfig\":{\"contentType\":\"text/plain\",\"statusCode\":\"404\",\"messageBody\":\"404 Not Found\"}}"
      "alb.ingress.kubernetes.io/wafv2-acl-arn"              = each.value.wafv2_acl_arn
      "alb.ingress.kubernetes.io/shield-advanced-protection" = each.value.shield_advanced_protection ? "true" : "false"
    }
  }

  spec {
    ingress_class_name = "alb"
    #
    # DO NOT USE AS THIS WILL LEAD TO CONFLICTS IN ALB RULES!
    #
    # rule {
    #   # With Kubernetes Provider 2.7.1 using an annotation cannot be used - TODO: FIXED WITH 2.8.0 https://github.com/hashicorp/terraform-provider-kubernetes/releases/tag/v2.8.0
    #   # TODO: Wait for next Provider Release
    #   # https://github.com/hashicorp/terraform-provider-kubernetes/pull/1541
    #   http {
    #     path {
    #       path      = "/*"
    #       path_type = "ImplementationSpecific"
    #       backend {
    #         service {
    #           name = "response-404"
    #           port {
    #             name = "use-annotation"
    #           }
    #         }
    #       }
    #     }
    #   }
    # }
    default_backend {
      service {
        name = "dummy-does-not-exist"
        port {
          number = 8080
        }
      }
    }
  }
}
