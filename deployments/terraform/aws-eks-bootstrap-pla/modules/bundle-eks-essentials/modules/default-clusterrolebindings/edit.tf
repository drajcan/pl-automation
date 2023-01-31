#
# Bind the Kubernetes Group 'edit' to the default cluster role 'edit'
# See https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
#
resource "kubernetes_cluster_role_binding" "edit" {
  metadata {
    name = "edit"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "Group"
    name      = local.crb_edit_group_name
    api_group = "rbac.authorization.k8s.io"
  }
}