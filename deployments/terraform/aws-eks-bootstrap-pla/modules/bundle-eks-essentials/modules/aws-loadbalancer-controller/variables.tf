variable "account_id" {
  type        = string
  description = "The 12 digit account id, e.g. 012345678901."
}
variable "region" {
  type        = string
  description = "AWS region of the EKS cluster."
}
variable "eks_cluster_name" {
  type        = string
  description = "The Name/ID of the EKS Cluster."
}
variable "oidc_provider_url" {
  type        = string
  description = "URL of the AWS OIDC Provider associated with the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}
variable "kubeconfig_filename" {
  type        = string
  description = "Path to Kubeconfig file"
}
variable "extra_assume_role_policy_statements" {
  description = "A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy."
  type        = list(any)
  default     = []
}
