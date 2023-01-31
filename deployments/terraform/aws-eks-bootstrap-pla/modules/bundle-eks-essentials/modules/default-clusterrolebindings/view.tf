#
# Bind the Kubernetes Group 'view' to the default cluster role 'view'
# See https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
#
resource "kubernetes_cluster_role_binding" "view" {
  metadata {
    name = "view"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }
  subject {
    kind      = "Group"
    name      = local.crb_view_group_name
    api_group = "rbac.authorization.k8s.io"
  }
}