
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws        = ">= 4.0, < 5.0"
    helm       = ">= 2.7.1"
    kubernetes = ">= 2.10"
    null       = ">= 2.1.0, < 4.0.0"
    time       = ">= 0.5.0"
  }
}
