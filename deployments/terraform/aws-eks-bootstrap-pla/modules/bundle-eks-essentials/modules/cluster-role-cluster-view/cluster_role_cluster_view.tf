#
# Aggregated clusterrole with permissions from default view role
#
#
# PLEASE NOTE: Using kubernetes_cluster_role is not working; see https://github.com/hashicorp/terraform-provider-kubernetes/issues/1303
#
# resource "kubernetes_cluster_role" "cluster_view" {
#   metadata {
#     name = "cluster-view"
#     annotations = {
#       description = "Aggregated role with permissions from default clusterrole 'view' and new clusterroles with aggregate-to-cluster-view"
#     }
#   }
#   aggregation_rule {
#     # Get same permissions as clusterrole view
#     cluster_role_selectors {
#       match_labels = {
#         "rbac.authorization.k8s.io/aggregate-to-view" : "true"
#       }
#     }
#     # Additional permissions - not working, see https://github.com/hashicorp/terraform-provider-kubernetes/issues/1303
#     cluster_role_selectors {
#       match_labels = {
#         "rbac.authorization.k8s.io/aggregate-to-cluster-view" : "true"
#       }
#     }
#   }
# }
#
#
# Please note: kubernetes_manifest also cannot be used as it requires a running Kubernetes at plan phase
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest
#
# resource "kubernetes_manifest" "clusterrole_cluster_view" {
#   manifest = {
#     "apiVersion" = "rbac.authorization.k8s.io/v1"
#     "kind"       = "ClusterRole"
#     "metadata" = {
#       "name" = "cluster-view"
#       "annotations" = {
#         "description" = "Aggregated role with permissions from default clusterrole 'view' and new clusterroles with aggregate-to-cluster-view"
#       }
#     }
#     "aggregationRule" = {
#       "clusterRoleSelectors" = [
#         {
#           "matchLabels" = {
#             "rbac.authorization.k8s.io/aggregate-to-view" = "true"
#           }
#         },
#         {
#           "matchLabels" = {
#             "rbac.authorization.k8s.io/aggregate-to-cluster-view" = "true"
#           }
#         }
#       ]
#     }
#   }
# }

# See https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a 
# why we use helm_release instead of kubernetes_manifest
resource "helm_release" "main" {
  name      = "clusterrole-cluster-view"
  namespace = "kube-system"

  chart = "${path.module}/../../../../files/charts/raw"

  values = [<<EOF
extraResources:
- |
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: cluster-view
    annotations:
      description: Aggregated role with permissions from default clusterrole 'view' and new clusterroles with aggregate-to-cluster-view
  aggregationRule:
    clusterRoleSelectors:
    - matchLabels:
        rbac.authorization.k8s.io/aggregate-to-view: "true"
    - matchLabels:
        rbac.authorization.k8s.io/aggregate-to-cluster-view: "true"

EOF
  ]
}


resource "kubernetes_cluster_role_binding" "cluster_view" {
  metadata {
    name = "cluster-view"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-view"
  }
  subject {
    kind      = "Group"
    name      = "cluster-view"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "aggregate_to_cluster_view" {
  metadata {
    name = "aggregate-to-cluster-view"
    labels = {
      "rbac.authorization.k8s.io/aggregate-to-cluster-view" = "true"
    }
    annotations = {
      description = "Additional rules for clusterrole cluster-view"
    }
  }
  dynamic "rule" {
    for_each = var.clusterrole_cluster_view_rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}
