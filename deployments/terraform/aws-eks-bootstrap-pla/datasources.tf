data "aws_eks_cluster" "main" {
  name = var.eks_cluster_name
}

#
# Necessary to detect EKS addon versions at terraform plan
#
data "aws_eks_addon_version" "coredns" {
  count = var.eks_managed_addons_settings.coredns_version == "latest" || var.eks_managed_addons_settings.coredns_version == "default" ? 1 : 0

  addon_name         = "coredns"
  kubernetes_version = data.aws_eks_cluster.main.version
  most_recent        = var.eks_managed_addons_settings.coredns_version == "latest"
}
data "aws_eks_addon_version" "kube_proxy" {
  count = var.eks_managed_addons_settings.kube_proxy_version == "latest" || var.eks_managed_addons_settings.kube_proxy_version == "default" ? 1 : 0

  addon_name         = "kube-proxy"
  kubernetes_version = data.aws_eks_cluster.main.version
  most_recent        = var.eks_managed_addons_settings.kube_proxy_version == "latest"
}
data "aws_eks_addon_version" "vpc_cni" {
  count = var.eks_managed_addons_settings.vpc_cni_version == "latest" || var.eks_managed_addons_settings.vpc_cni_version == "default" ? 1 : 0

  addon_name         = "vpc-cni"
  kubernetes_version = data.aws_eks_cluster.main.version
  most_recent        = var.eks_managed_addons_settings.vpc_cni_version == "latest"
}