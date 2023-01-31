#
# Minimal required variables
#
variable "account_id" {
  description = "The 12 digit account id, e.g. 012345678901."
  type        = string
}
variable "region" {
  description = "AWS Region, e.g. eu-central-1"
  type        = string
}
variable "kubeconfig_filename" {
  description = "The filename of an existing kubeconfig file."
  type        = string
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "extra_assume_role_policy_statements" {
  description = "A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy for each IAM role. This is useful in case each of your IAM role gets additional policy statements attached by automation rules."
  type        = list(any)
  default     = []
}

#
# EKS settings
#
variable "eks_managed_addons_settings" {
  type = object({
    coredns_version    = string
    kube_proxy_version = string
    vpc_cni_version    = string
  })
  description = "The versions of the managed Add-Ons coredns, kube-proxy and vpc-cni - Either 'latest', 'default' or a specific version e.g. 'v1.8.7-eksbuild.2'."
  default = {
    coredns_version    = "latest"
    kube_proxy_version = "latest"
    vpc_cni_version    = "latest"
  }
}

variable "k8s_create_clusterrole_cluster_view" {
  description = "Whether to create clusterrole cluster-view with same rules as default clusterrole view and further rules (see k8s_clusterrole_cluster_view_rules) or not."
  type        = bool
  default     = true
}
variable "k8s_clusterrole_cluster_view_rules" {
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



#
# AWS LoadBalancer Controller Group default settings
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
  default     = {}
}

#
# Kubernetes Dashboard
#
variable "k8s_dashboard_ingress_enabled" {
  type        = bool
  description = "Whether to expose Kubernetes Dashboard via an ingress to the outside world or not. If 'true' also set valid values for 'ingress_settings' and 'oidc_client_secret'"
  default     = false
}
variable "k8s_dashboard_ingress_settings" {
  type = object({
    ingress_group               = string
    host_name                   = string
    oidc_enabled                = bool
    oidc_client_id              = string # The RedirectURI must end with "/oauth2/idpresponse" and look like this "https://hostname/oauth2/idpresponse"
    oidc_issuer                 = string # e.g. https://login.microsoftonline.com/TENANT_ID/v2.0
    oidc_authorization_endpoint = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
    oidc_token_endpoint         = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
    oidc_user_info_endpoint     = string # e.g. https://graph.microsoft.com/oidc/userinfo
  })
  description = <<EOF
Settings for configuring AWS ALB via Load Balancer Controller.
ingress_group=name of the ingress group, 
host_name=Host name for K8S Dashboard, 
oidc_enabled=Whether to enable OIDC/OAuth2 at AWS ALB (strongly recommended) or not
oidc_client_id=The OIDC client ID; the RedirectURI must end with "/oauth2/idpresponse" and look like this "https://hostname/oauth2/idpresponse",
oidc_issuer=The issuer of the token, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/v2.0
oidc_authorization_endpoint=The authz endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
oidc_token_endpoint=The token endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
oidc_user_info_endpoint=UserInfo endpoint, e.g. for Azure AD https://graph.microsoft.com/oidc/userinfo
EOF

  default = null
}
variable "k8s_dashboard_ingress_oidc_client_secret" {
  type        = string
  description = "OIDC Client Secret for AWS ALB"
  default     = null
  sensitive   = true
}

#
# Grafana
#
variable "grafana_ingress_enabled" {
  type        = bool
  description = "Whether to expose Grafana via an ingress to the outside world or not. If 'true' also set valid values for 'grafana_ingress_settings' and 'grfana_ingress_oidc_client_secret'"
  default     = false
}
variable "grafana_ingress_settings" {
  type = object({
    ingress_group               = string
    host_name                   = string
    oidc_enabled                = bool
    oidc_client_id              = string # The RedirectURI must end with "/oauth2/idpresponse" and look like this "https://hostname/oauth2/idpresponse"
    oidc_issuer                 = string # e.g. https://login.microsoftonline.com/TENANT_ID/v2.0
    oidc_authorization_endpoint = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
    oidc_token_endpoint         = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
    oidc_user_info_endpoint     = string # e.g. https://graph.microsoft.com/oidc/userinfo
  })
  description = <<EOF
Settings for configuring AWS ALB via Load Balancer Controller.
ingress_group=name of the ingress group, 
host_name=Host name for Grafana, 
oidc_enabled=Whether to enable OIDC/OAuth2 at AWS ALB (strongly recommended) or not
oidc_client_id=The OIDC client ID; the RedirectURI must end with "/oauth2/idpresponse" and look like this "https://hostname/oauth2/idpresponse"
oidc_issuer=The issuer of the token, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/v2.0
oidc_authorization_endpoint=The authz endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
oidc_token_endpoint=The token endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
oidc_user_info_endpoint=UserInfo endpoint, e.g. for Azure AD https://graph.microsoft.com/oidc/userinfo
EOF
  default     = null
}
variable "grafana_ingress_oidc_client_secret" {
  type        = string
  description = "OIDC Client Secret for AWS ALB"
  sensitive   = true
  default     = null
}

variable "grafana_azuread_auth_enabled" {
  type        = bool
  description = "Whether to enabled Single-Sign-On with Azure AD. If enabled, provide 'azuread_auth_settings' and 'azuread_auth_client_secret'. See https://grafana.com/docs/grafana/v9.0/setup-grafana/configure-security/configure-authentication/azuread/"
  default     = false
}
variable "grafana_azuread_auth_settings" {
  type = object({
    org_name        = string # e.g. PharmaLedger
    client_id       = string # The RedirectURI must end with "/login/azuread" and look like this "https://hostname/login/azuread"
    auth_url        = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
    token_url       = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
    allowed_domains = string # e.g. pharmaledger.org,pharmaledger.eu
  })
  description = <<EOF
Settings for configuring SSO at Grafana with Azure AD.
org_nameThe Name of the organization, e.g. PharmaLedger, 
client_id=The OIDC/OAuth2 Client ID; the RedirectURI must end with "/login/azuread" and look like this "https://hostname/login/azuread",
auth_url=The authz endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
token_url=The token endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
allowed_domains=A space or comma seperated list of allowed domain, e.g. pharmaledger.org,pharmaledger.eu
EOF
  default     = null
}
variable "grafana_azuread_auth_client_secret" {
  type        = string
  description = "OIDC Client Secret for authentication at Grafana itself via Azure AD"
  sensitive   = true
  default     = null
}
