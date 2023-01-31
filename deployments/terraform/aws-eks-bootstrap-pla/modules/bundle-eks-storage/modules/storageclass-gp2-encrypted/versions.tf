
terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = ">= 2.10"
    null       = ">= 2.1.0, < 4.0.0"
  }
}
