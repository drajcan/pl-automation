module "bootstrapping" {
  # IMPORTANT: The source can be either
  # a) a copy of this repository into your own repo (local copy), e.g. to `modules/aws-eks-bootstrapping` - `source = "./modules/aws-eks-bootstrapping"`
  # b) a copy of this repository into a dedicated repo of your choice. See https://developer.hashicorp.com/terraform/language/modules/sources for configuring the module source.
  source = "../" # for the example, we reference the module in this repo

  region              = var.region
  eks_cluster_name    = var.eks_cluster_name
  account_id          = var.account_id
  kubeconfig_filename = var.kubeconfig_filename
}