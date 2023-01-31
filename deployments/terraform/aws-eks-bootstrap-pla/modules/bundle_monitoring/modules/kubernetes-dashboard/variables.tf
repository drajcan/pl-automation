variable "ingress_enabled" {
  type        = bool
  description = "Whether to expose Kubernetes Dashboard via an ingress to the outside world or not. If 'true' also set valid values for 'ingress_settings' and 'oidc_client_secret'"
  default     = false
}
variable "ingress_settings" {
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

  default = null
}
variable "ingress_oidc_client_secret" {
  type        = string
  description = "OIDC Client Secret for AWS ALB"
  default     = null
  sensitive   = true
}
