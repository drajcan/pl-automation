
variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

#
# EKS settings
#
variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}
variable "eks_cluster_version" {
  type    = string
  default = "1.24"
}
variable "eks_cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "Number of days to retain cluster log events"
  default     = 30
}
variable "eks_cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  default     = ["0.0.0.0/0"]
}
# variable "eks_kubeconfig_output_path" {
#   type        = string
#   description = "The Path to the Kubeconfig file. If not set uses kubeconfig in the root module"
#   default     = null
# }
# variable "eks_write_kubeconfig" {
#   description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to `eks_kubeconfig_output_path`."
#   type        = bool
#   default     = false
# }
# variable "eks_workers_group_defaults" {
#   description = "Override default values for target groups. See workers_group_defaults_defaults in https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.32.0/local.tf for valid keys."
#   type        = any
#   default = {
#     root_volume_type = "gp3"
#   }
# }
variable "eks_fargate_profiles" {
  description = "Fargate Profiles"
  type        = map(any)
  default     = {}
  # default = {
  #   kube-system = {
  #     name = "kube-system"
  #     selectors = [
  #       {
  #         namespace = "kube-system"
  #       }
  #     ]
  #   }
  # }
}
variable "eks_cluster_enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
  description = "List of enabled log types"
}
variable "eks_managed_node_groups" {
  type        = any
  description = "Map of map of node groups to create. - see https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v18.30.2/modules/eks-managed-node-group for details. Please note: For Cluster Autoscaler to work properly an AutoScalingGroup (ASG) must be bound to exactly one availability zone (AZ)! Therefore a single node group shall not use more than one subnet/AZ."
  default     = {}
}

# variable "eks_attach_worker_cni_policy" {
#   description = "Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster."
#   type        = bool
#   default     = false
# }
variable "eks_enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = true
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
variable "eks_aws_auth_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

#
# VPC Settings
#
variable "vpc_azs" {
  type        = list(string)
  description = "Must be exactly two, three or four availability zones, e.g. eu-central-1a, eu-central-1b, eu-central-1c"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR range for the VPC"
  default     = "10.0.0.0/16"
}
variable "vpc_public_subnets" {
  type        = list(string)
  description = "CIDR ranges for the public subnets; by default 1019 IPv4 addresses per subnet. If vpc_azs contains three values, then the first 3 subnets will be used."
  default     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22", "10.0.12.0/22"]
}
variable "vpc_private_subnets" {
  type        = list(string)
  description = "CIDR ranges for the private subnets; by default 4091 IPv4 addresses per subnet. If vpc_azs contains three values, then the first 3 subnets will be used."
  default     = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20", "10.0.64.0/20"]
}
variable "vpc_create_database_subnets" {
  type        = bool
  description = "Whether to create intra database or not"
  default     = false
}
variable "vpc_database_subnets" {
  type        = list(string)
  description = "CIDR ranges for the database subnets; by default 1019 IPv4 addresses per subnet. If vpc_azs contains three values, then the first 3 subnets will be used."
  default     = ["10.0.80.0/22", "10.0.84.0/22", "10.0.88.0/22", "10.0.92.0/22"]
}
variable "vpc_create_intra_subnets" {
  type        = bool
  description = "Whether to create intra subnets or not"
  default     = false
}
variable "vpc_intra_subnets" {
  type        = list(string)
  description = "CIDR ranges for the intra subnets; by default 1019 IPv4 addresses per subnet. If vpc_azs contains three values, then the first 3 subnets will be used."
  default     = ["10.0.96.0/22", "10.0.100.0/22", "10.0.104.0/22", "10.0.108.0/22"]
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
variable "vpc_reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}
variable "vpc_external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}
variable "vpc_create_database_internet_gateway_route" {
  type        = bool
  description = "Controls if an internet gateway route for public database access should be created"
  default     = false
}
#
# VPC Logging
#
variable "vpc_enable_flow_log_cloudwatch" {
  type        = bool
  description = "Boolean if VPC Flow log to Cloudwatch will be created"
  default     = true
}
variable "vpc_flow_log_cloudwatch_retention_in_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 30
}
