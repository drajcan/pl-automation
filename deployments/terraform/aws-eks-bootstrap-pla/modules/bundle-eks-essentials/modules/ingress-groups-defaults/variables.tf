variable "eks_cluster_name" {
  type        = string
  description = "The Name/ID of the EKS Cluster."
}
#
# Ingress default group settings
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
