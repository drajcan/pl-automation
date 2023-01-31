#
# EKS-Managed Add-On Core-DNS (aka coredns)
#
# https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
# Find matching add-on versions: aws eks describe-addon-versions --kubernetes-version 1.22 --addon-name kube-proxy
#
resource "aws_eks_addon" "main" {
  cluster_name      = var.eks_cluster_name
  addon_name        = "kube-proxy"
  addon_version     = var.addon_version
  resolve_conflicts = "OVERWRITE"
}