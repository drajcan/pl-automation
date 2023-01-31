module "prometheus" {
  source = "./modules/prometheus"
}
module "kubernetes_dashboard" {
  source = "./modules/kubernetes-dashboard"

  ingress_enabled            = var.k8s_dashboard_ingress_enabled
  ingress_settings           = var.k8s_dashboard_ingress_settings
  ingress_oidc_client_secret = var.k8s_dashboard_ingress_oidc_client_secret
}

module "grafana" {
  source = "./modules/grafana"

  account_id                          = var.account_id
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements

  ingress_enabled            = var.grafana_ingress_enabled
  ingress_settings           = var.grafana_ingress_settings
  ingress_oidc_client_secret = var.grafana_ingress_oidc_client_secret

  azuread_auth_enabled       = var.grafana_azuread_auth_enabled
  azuread_auth_settings      = var.grafana_azuread_auth_settings
  azuread_auth_client_secret = var.grafana_azuread_auth_client_secret
}