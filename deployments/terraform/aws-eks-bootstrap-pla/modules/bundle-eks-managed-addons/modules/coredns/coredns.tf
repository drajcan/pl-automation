#
# EKS-Managed Add-On Core-DNS (aka coredns)
#
# https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
# Find matching add-on version: aws eks describe-addon-versions --kubernetes-version 1.22 --addon-name coredns
#
# Note: 
# 1. As all addons, CoreDNS is also being deployed as so called unmanaged addon with every new EKS cluster.
# 2. If deploying the CoreDNS EKS managed addon "over" the existing "unmanaged" deployment with the same image version, 
# NO change/update will be triggered. If also a Fargate profile exists for kube-system namespace, the pending CoreDNS pods keep pending indefinitely 
# as they are not being scheduled for Fargate.
# 3. Deleting the existing deployment prior to managed addon deployment helps to schedule CoreDNS at Fargate.
resource "null_resource" "prerequisites" {
  provisioner "local-exec" {
    command = <<EOF
    kubectl --kubeconfig ${var.kubeconfig_filename} --namespace kube-system --ignore-not-found=true --wait=true delete deployment coredns
EOF
  }
}

resource "aws_eks_addon" "main" {
  depends_on = [null_resource.prerequisites]

  cluster_name      = var.eks_cluster_name
  addon_name        = "coredns"
  addon_version     = var.addon_version
  resolve_conflicts = "OVERWRITE"
}