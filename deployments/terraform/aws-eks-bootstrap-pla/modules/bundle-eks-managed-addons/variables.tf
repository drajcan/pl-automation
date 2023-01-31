variable "account_id" {
  type        = string
  description = "The 12 digit account id, e.g. 012345678901."
}
variable "eks_cluster_name" {
  type        = string
  description = "The Name/ID of the EKS Cluster."
}
variable "oidc_provider_url" {
  type        = string
  description = "URL of the AWS OIDC Provider associated with the EKS cluster"
}
variable "extra_assume_role_policy_statements" {
  description = "A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy."
  type        = list(any)
  default     = []
}

variable "kubeconfig_filename" {
  type        = string
  description = "Path to Kubeconfig file"
}

variable "vpc_cni_version" {
  type        = string
  description = "The version of the managed Add-On vpc-cni - Either 'latest', 'default' or a specific version 'v1.11.4-eksbuild.1'."
}
variable "kube_proxy_version" {
  type        = string
  description = "The version of the managed Add-On kube-proxy - Either 'latest', 'default' or a specific version 'v1.22.11-eksbuild.2'."
}
variable "coredns_version" {
  type        = string
  description = "The version of the managed Add-On coredns - Either 'latest', 'default' or a specific version 'v1.8.7-eksbuild.2'."
}
