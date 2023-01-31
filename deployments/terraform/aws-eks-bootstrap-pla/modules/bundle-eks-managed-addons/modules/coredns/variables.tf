variable "eks_cluster_name" {
  type        = string
  description = "The Name/ID of the EKS Cluster."
}
variable "kubeconfig_filename" {
  type        = string
  description = "Path to Kubeconfig file"
}
variable "addon_version" {
  type        = string
  description = "The version of the managed Add-On coredns."
}
