variable "clusterrole_cluster_view_rules" {
  description = "Additional rules for clusterrole cluster-view added to rules from default clusterrole view"
  type = list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  }))
  default = [
    {
      api_groups = [""]
      resources  = ["secrets"]
      verbs      = ["list"]
    },
    {
      api_groups = ["rbac.authorization.k8s.io"]
      resources  = ["clusterroles", "clusterrolebindings", "rolebindings", "roles"]
      verbs      = ["list", "get"]
    },
    {
      api_groups = ["apiextensions.k8s.io"]
      resources  = ["customresourcedefinitions"]
      verbs      = ["list"]
    }
  ]
}