locals {
  coredns_addon_version    = var.eks_managed_addons_settings.coredns_version == "latest" || var.eks_managed_addons_settings.coredns_version == "default" ? data.aws_eks_addon_version.coredns[0].version : var.eks_managed_addons_settings.coredns_version
  kube_proxy_addon_version = var.eks_managed_addons_settings.kube_proxy_version == "latest" || var.eks_managed_addons_settings.kube_proxy_version == "default" ? data.aws_eks_addon_version.kube_proxy[0].version : var.eks_managed_addons_settings.kube_proxy_version
  vpc_cni_addon_version    = var.eks_managed_addons_settings.vpc_cni_version == "latest" || var.eks_managed_addons_settings.vpc_cni_version == "default" ? data.aws_eks_addon_version.vpc_cni[0].version : var.eks_managed_addons_settings.vpc_cni_version
}
