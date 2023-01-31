terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = ">= 2.10"
    helm       = ">= 2.7.1"
  }
}