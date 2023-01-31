data "aws_eks_cluster" "main" {
  name = var.eks_cluster_name
}
