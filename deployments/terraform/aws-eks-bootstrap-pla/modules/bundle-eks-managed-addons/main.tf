module "vpc_cni" {
  source = "./modules/vpc-cni"

  account_id                          = var.account_id
  eks_cluster_name                    = var.eks_cluster_name
  oidc_provider_url                   = var.oidc_provider_url
  addon_version                       = var.vpc_cni_version
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
}

module "kube_proxy" {
  depends_on = [module.vpc_cni]

  source = "./modules/kube-proxy"

  eks_cluster_name = var.eks_cluster_name
  addon_version    = var.kube_proxy_version
}

module "coredns" {
  depends_on = [
    module.vpc_cni,
    module.kube_proxy
  ]

  source = "./modules/coredns"

  eks_cluster_name    = var.eks_cluster_name
  addon_version       = var.coredns_version
  kubeconfig_filename = var.kubeconfig_filename
}
