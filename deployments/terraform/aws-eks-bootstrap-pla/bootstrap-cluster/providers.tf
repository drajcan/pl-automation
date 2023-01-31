provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "CreatedBy"          = "PharmaLedger Association"
      "ManagedBy"          = "Terraform"
      "Project"            = "PharmaLedger"
      "TechnicalContact_1" = "firstname1.lastname1@pharmaledger.org"
      "TechnicalContact_2" = "firstname2.lastname2@pharmaledger.org"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}
provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority[0].data, [""]), 0))
  # Important: We cannot use the token. It seems that the token is being retrieved at terraform plan phase.
  # At plan phase we use a principal with readonly permissions. 
  # This means, any changes at apply phase will be tried with readonly permissions and will fail.
  # Therefore we retrieve a fresh token via aws eks command
  #  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--region", var.region]
    command     = "aws"
  }
}
provider "helm" {
  kubernetes {
    host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
    cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority[0].data, [""]), 0))
    # Important: We cannot use the token. It seems that the token is being retrieved at terraform plan phase.
    # At plan phase we use a principal with readonly permissions. 
    # This means, any changes at apply phase will be tried with readonly permissions and will fail.
    # Therefore we retrieve a fresh token via aws eks command
    #  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_name, "--region", var.region]
      command     = "aws"
    }
  }
}
