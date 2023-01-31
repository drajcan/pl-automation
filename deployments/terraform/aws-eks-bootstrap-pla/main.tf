#
# 0. Always create an S3 Bucket for Load Balancer Logging.even it will not be used.
# Otherwise there may be a race condition on terraform destroy
#
module "loadbalancer_logging_s3_bucket" {
  source = "./modules/loadbalancer-access-log-s3-bucket"

  name   = "${var.eks_cluster_name}-loadbalancer-logging"
  region = var.region
}

#
# 1. Turn default unmanaged addons (kube-proxy, coreDNS, VPC CNI aka aws-node) into EKS managed addons
#
module "bundle_eks_managed_addons" {
  source = "./modules/bundle-eks-managed-addons"

  account_id                          = var.account_id
  eks_cluster_name                    = data.aws_eks_cluster.main.id
  oidc_provider_url                   = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  kubeconfig_filename                 = var.kubeconfig_filename
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements

  vpc_cni_version    = local.vpc_cni_addon_version
  coredns_version    = local.coredns_addon_version
  kube_proxy_version = local.kube_proxy_addon_version
}

#
# 2. Essential components
#
module "bundle_eks_essentials" {
  depends_on = [
    module.bundle_eks_managed_addons,
    # This dependency is necessary. 
    # Otherwise a race condition may occur on terraform destroy when the S3 bucket has been deleted before the ingress groups.
    # In this case the Load Balancer controller complains about it and the deletion of the ingress fails!
    module.loadbalancer_logging_s3_bucket
  ]

  source = "./modules/bundle-eks-essentials"

  account_id                          = var.account_id
  region                              = var.region
  eks_cluster_name                    = data.aws_eks_cluster.main.id
  oidc_provider_url                   = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  kubeconfig_filename                 = var.kubeconfig_filename

  vpc_id         = data.aws_eks_cluster.main.vpc_config[0].vpc_id
  ingress_groups = var.ingress_groups

  create_clusterrole_cluster_view = var.k8s_create_clusterrole_cluster_view
  clusterrole_cluster_view_rules  = var.k8s_clusterrole_cluster_view_rules
}
#
# 3. Storage components
#
module "bundle_eks_storage" {
  depends_on = [module.bundle_eks_essentials]

  source = "./modules/bundle-eks-storage"

  account_id                          = var.account_id
  region                              = var.region
  eks_cluster_name                    = data.aws_eks_cluster.main.id
  oidc_provider_url                   = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  kubeconfig_filename                 = var.kubeconfig_filename
}

#
# 4. Monitoring components
#
module "bundle_monitoring" {
  depends_on = [
    module.bundle_eks_essentials,
    module.bundle_eks_storage
  ]

  source = "./modules/bundle_monitoring"

  account_id                          = var.account_id
  eks_cluster_name                    = data.aws_eks_cluster.main.id
  oidc_provider_url                   = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements

  k8s_dashboard_ingress_enabled            = var.k8s_dashboard_ingress_enabled
  k8s_dashboard_ingress_settings           = var.k8s_dashboard_ingress_settings
  k8s_dashboard_ingress_oidc_client_secret = var.k8s_dashboard_ingress_oidc_client_secret

  grafana_ingress_enabled            = var.grafana_ingress_enabled
  grafana_ingress_settings           = var.grafana_ingress_settings
  grafana_ingress_oidc_client_secret = var.grafana_ingress_oidc_client_secret

  grafana_azuread_auth_enabled       = var.grafana_azuread_auth_enabled
  grafana_azuread_auth_settings      = var.grafana_azuread_auth_settings
  grafana_azuread_auth_client_secret = var.grafana_azuread_auth_client_secret
}