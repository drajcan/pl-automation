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

#
# Kubernetes Dashboard
#
variable "k8s_dashboard_ingress_enabled" {
  type        = bool
  description = "Whether to expose Kubernetes Dashboard via an ingress to the outside world or not. If 'true' also set valid values for 'k8s_dashboard_ingress_settings' and 'oidc_client_secret'"
  default     = false
}
variable "k8s_dashboard_ingress_settings" {
  type = object({
    ingress_group               = string
    host_name                   = string
    oidc_enabled                = bool
    oidc_client_id              = string
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
oidc_client_id=The OIDC client ID
oidc_issuer=The issuer of the token, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/v2.0
oidc_authorization_endpoint=The authz endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
oidc_token_endpoint=The token endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
oidc_user_info_endpoint=UserInfo endpoint, e.g. for Azure AD https://graph.microsoft.com/oidc/userinfo
EOF
  default     = null
}
variable "k8s_dashboard_ingress_oidc_client_secret" {
  type        = string
  description = "OIDC Client Secret for AWS ALB"
  sensitive   = true
  default     = null
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
    oidc_client_id              = string
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
oidc_client_id=The OIDC client ID
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
    client_id       = string
    auth_url        = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize
    token_url       = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token
    allowed_domains = string # e.g. pharmaledger.org,pharmaledger.eu
  })
  description = <<EOF
Settings for configuring SSO at Grafana with Azure AD.
org_nameThe Name of the organization, e.g. PharmaLedger, 
client_id=The OIDC/OAuth2 Client ID, 
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
