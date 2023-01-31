provider "aws" {
  region = var.region
  default_tags {
    tags = var.tag_git_repo_url == "" ? var.provider_default_tags : merge({
      "git_repo_url" = var.tag_git_repo_url
    }, var.provider_default_tags)
  }
  ignore_tags {
    keys = var.provider_ignore_tags
  }
}
#
# Kubernetes Provider required in order to maintain authmap
#
provider "kubernetes" {
  host                   = module.cluster.this_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.this_eks_cluster_certificate_authority_data)
  # Important: We cannot use the token. It seems that the token is being retrieved at terraform plan phase.
  # At plan phase we use a principal with readonly permissions. 
  # This means, any changes at apply phase will be tried with readonly permissions and will fail.
  # Therefore we retrieve a fresh token via aws eks command
  #  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.this_eks_cluster_name, "--region", var.region]
    command     = "aws"
  }
}
