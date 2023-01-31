variable "account_id" {
  type        = string
  description = "The 12 digit account id, e.g. 012345678901."
}
variable "region" {
  type        = string
  description = "The AWS region, defaults to eu-central-1"
  default     = "eu-central-1"
}
variable "eks_cluster_name" {
  description = "Name/ID of the EKS Cluster"
  type        = string
}
variable "kubeconfig_filename" {
  description = "The filename of an existing kubeconfig file."
  type        = string
  default     = "kubeconfig.yaml"
}
