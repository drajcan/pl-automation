#
# Log collector
#
module "aws_fluent_bit" {
  source = "./modules/aws-fluent-bit"

  account_id                          = var.account_id
  region                              = var.region
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
}
#
# Load Balancer Controller and default ingress groups
#
module "aws_loadbalancer_controller" {
  source = "./modules/aws-loadbalancer-controller"

  account_id                          = var.account_id
  region                              = var.region
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements

  vpc_id              = var.vpc_id
  kubeconfig_filename = var.kubeconfig_filename
}
module "ingress_groups_defaults" {
  depends_on = [module.aws_loadbalancer_controller]

  source = "./modules/ingress-groups-defaults"

  eks_cluster_name = var.eks_cluster_name
  ingress_groups   = var.ingress_groups
}

#
# Cluster Autoscaler
#
module "cluster_autoscaler" {
  source = "./modules/cluster-autoscaler"

  account_id                          = var.account_id
  region                              = var.region
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
}

#
# External DNS
#
module "external_dns" {
  source = "./modules/external-dns"

  account_id                          = var.account_id
  region                              = var.region
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
}

#
# Metrics Server
#
module "metrics_server" {
  source = "./modules/metrics-server"
}

module "calico_tigera_operator" {
  count  = var.calico_install_flag ? 1 : 0
  source = "./modules/calico-tigera-operator"
}

#
# Creates clusterrolebindings for the default clusterroles - https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
#
# Bind Clusterrole admin to Group admin
# Bind Clusterrole edit  to Group edit
# Bind Clusterrole view  to Group view
module "default_clusterrolebindings" {
  source = "./modules/default-clusterrolebindings"
}

module "cluster_role_cluster_view" {
  count = var.create_clusterrole_cluster_view ? 1 : 0

  source = "./modules/cluster-role-cluster-view"

  clusterrole_cluster_view_rules = var.clusterrole_cluster_view_rules
}
