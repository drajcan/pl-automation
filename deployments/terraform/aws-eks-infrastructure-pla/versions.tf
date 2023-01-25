
terraform {
  required_version = ">= 1.0"

  required_providers {
    # default tags supported from > 3.38 https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider
    # tags for aws_elasticache_parameter_group > 3.43
    aws        = ">= 4.47"
    kubernetes = ">= 2.10"
  }
}
