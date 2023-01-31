variable "eks_cluster_name" {
  type        = string
  description = "The Name/ID of the EKS Cluster."
}
variable "addon_version" {
  type        = string
  description = "The version of the managed Add-On kube-proxy."
}
