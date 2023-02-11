variable "account_id" {
  type        = string
  description = "The 12 digit account id, e.g. 012345678901."
}
variable "region" {
  type        = string
  description = "The AWS Region"
}
variable "tag_git_repo_url" {
  type        = string
  description = "The URL of the Git repository. If it is a non empty string, it Will be merged into default_tags with key 'git_repo_url'"
  default     = ""
}
variable "provider_default_tags" {
  type        = map(string)
  description = "Default tags for AWS resources"
  default     = {}
}
variable "provider_ignore_tags" {
  type        = list(string)
  description = "A list of tags to ignore for the AWS provider"
  default     = []
}

variable "eks_cluster_name" {
  type        = string
  description = "The Name of the cluster. Will also be used as identifier for multiple resources."
}
variable "eks_aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.4.0#input_aws_auth_roles"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "eks_aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "vpc_single_nat_gateway" {
  type        = bool
  default     = false
  description = "True to deploy only a single NAT Gateway for whole VPC"
}
variable "vpc_one_nat_gateway_per_az" {
  type        = bool
  default     = true
  description = "True to deploy a NAT Gateway for each AZ"
}
variable "vpc_external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}
