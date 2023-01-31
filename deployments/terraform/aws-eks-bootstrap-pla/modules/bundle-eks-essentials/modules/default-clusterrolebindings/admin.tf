#
# Bind the Kubernetes Group 'admin' to the default cluster role 'admin'
# See https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
#
resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "Group"
    name      = local.crb_admin_group_name
    api_group = "rbac.authorization.k8s.io"
  }
}