#
# EKS-Managed Add-On VPC-CNI (aka aws-node)
# Find matching add-on version: aws eks describe-addon-versions --kubernetes-version 1.22 --addon-name vpc-cni
#
# Common:  https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
# AWS/IAM: https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
# https://dev.to/aws-builders/understand-pods-communication-338c
#

# 1. IAM Role
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id                          = var.account_id
  oidc_provider_url                   = var.oidc_provider_url
  extra_assume_role_policy_statements = var.extra_assume_role_policy_statements
  name                                = "${var.eks_cluster_name}-aws-node"
  service_accounts                    = ["kube-system/aws-node"]
  policy_arns                         = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}

# 2. Managed add-on
resource "aws_eks_addon" "main" {
  depends_on = [module.iam_role]

  cluster_name             = var.eks_cluster_name
  addon_name               = "vpc-cni"
  addon_version            = var.addon_version
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = module.iam_role.this_role_arn
}
