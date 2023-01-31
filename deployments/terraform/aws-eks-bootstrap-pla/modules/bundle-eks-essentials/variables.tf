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
variable "extra_assume_role_policy_statements" {
  description = "A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy."
  type        = list(any)
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}
variable "kubeconfig_filename" {
  type        = string
  description = "Path to Kubeconfig file"
}
#
# Ingress groups default settings
#
variable "ingress_groups" {
  type = map(object({
    certificate_arn             = string
    idle_timeout_seconds        = number
    deletion_protection_enabled = bool
    wafv2_acl_arn               = string
    shield_advanced_protection  = bool
    s3_logging_enabled          = bool
    s3_logging_bucket_name      = string
    s3_logging_prefix           = string
  }))
  description = <<EOF
Default ingress settings implemented as Kubernetes ingress. Key is the groupName. Contains redirect from port 80 to 443, logging settings, SSL certificate, optional WAF v2 ACL attachment.
certificate_arn=Specifies the ARN of one or more certificate managed by AWS Certificate Manager; can be a single ARN or a list of ARNs seperated by comma.
idle_timeout_seconds=The idle timeout.
deletion_protection_enabled=Whether to enable deletion protection of the ALB or not.
wafv2_acl_arn=Specifies ARN for the Amazon WAFv2 web ACL. Can be null to not use a WAF.
shield_advanced_protection=turns on / off the AWS Shield Advanced protection for the load balancer.
s3_logging_enabled=Whether to enabled logging to S3 or not.
s3_logging_bucket_name=Name of the S3 bucket used for logging.
s3_logging_prefix=String literal used as prefix, e.g. my-app
EOF
}


#
# Calico
#
variable "calico_install_flag" {
  type        = bool
  description = "Whether to install Calico or not."
  default     = false
}

#
# ClusterRole cluster-view
#
variable "create_clusterrole_cluster_view" {
  description = "Whether to create clusterrole cluster-view with same rules as default clusterrole view and further rules (see clusterrole_cluster_view_rules) or not."
  type        = bool
  default     = true
}
variable "clusterrole_cluster_view_rules" {
  description = "Additional rules for clusterrole cluster-view added to rules from default clusterrole view"
  type = list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  }))
  default = [
    {
      api_groups = [""]
      resources  = ["secrets"]
      verbs      = ["list"]
    },
    {
      api_groups = ["rbac.authorization.k8s.io"]
      resources  = ["clusterroles", "clusterrolebindings", "rolebindings", "roles"]
      verbs      = ["list", "get"]
    },
    {
      api_groups = ["apiextensions.k8s.io"]
      resources  = ["customresourcedefinitions"]
      verbs      = ["list"]
    }
  ]
}
