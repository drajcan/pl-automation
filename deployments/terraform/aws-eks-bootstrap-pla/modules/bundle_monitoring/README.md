# aws-eks-addons

Common (unmanaged) Add-Ons for AWS EKS

- [AWS Load Balancer Controller](https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller)
- [Cluster Autoscaler](https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler)
- [External DNS](https://github.com/bitnami/charts/tree/master/bitnami/external-dns)
- [Calico](https://docs.aws.amazon.com/eks/latest/userguide/calico.html)
- [Metrics Server](https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html)

## Usage

Minimal setup

```hcl
module "eks_addons" {
  source = "./modules/aws-eks-addons"

  account_id                               = var.account_id
  region                                   = var.region
  eks_cluster_name                         = module.eks.cluster_id
  oidc_provider_url                        = module.eks.cluster_oidc_issuer_url
  vpc_id                                   = module.vpc.vpc_id
  kubeconfig_filename                      = module.eks.kubeconfig_filename

  depends_on = [module.eks_managed_addons]
}
```

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).
Follow [these instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) to install pre-commit locally and install `terraform-docs` either via download from [github.com](https://github.com/terraform-docs/terraform-docs/releases) or via package managers `go get github.com/segmentio/terraform-docs` or `brew install terraform-docs`.

1. Pay attention that a `README.md` file **must be utf-8 encoded**!
2. Does not work on Windows, use Linux or Mac instead!

## Terraform Module Details

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.1.0, < 4.0.0 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_grafana"></a> [grafana](#module\_grafana) | ./modules/grafana | n/a |
| <a name="module_kubernetes_dashboard"></a> [kubernetes\_dashboard](#module\_kubernetes\_dashboard) | ./modules/kubernetes-dashboard | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./modules/prometheus | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The 12 digit account id, e.g. 012345678901. | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The Name/ID of the EKS Cluster. | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL of the AWS OIDC Provider associated with the EKS cluster | `string` | n/a | yes |
| <a name="input_extra_assume_role_policy_statements"></a> [extra\_assume\_role\_policy\_statements](#input\_extra\_assume\_role\_policy\_statements) | A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy. | `list(any)` | `[]` | no |
| <a name="input_grafana_azuread_auth_client_secret"></a> [grafana\_azuread\_auth\_client\_secret](#input\_grafana\_azuread\_auth\_client\_secret) | OIDC Client Secret for authentication at Grafana itself via Azure AD | `string` | `null` | no |
| <a name="input_grafana_azuread_auth_enabled"></a> [grafana\_azuread\_auth\_enabled](#input\_grafana\_azuread\_auth\_enabled) | Whether to enabled Single-Sign-On with Azure AD. If enabled, provide 'azuread\_auth\_settings' and 'azuread\_auth\_client\_secret'. See https://grafana.com/docs/grafana/v9.0/setup-grafana/configure-security/configure-authentication/azuread/ | `bool` | `false` | no |
| <a name="input_grafana_azuread_auth_settings"></a> [grafana\_azuread\_auth\_settings](#input\_grafana\_azuread\_auth\_settings) | Settings for configuring SSO at Grafana with Azure AD.<br>org\_nameThe Name of the organization, e.g. PharmaLedger, <br>client\_id=The OIDC/OAuth2 Client ID, <br>auth\_url=The authz endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize<br>token\_url=The token endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token<br>allowed\_domains=A space or comma seperated list of allowed domain, e.g. pharmaledger.org,pharmaledger.eu | <pre>object({<br>    org_name        = string # e.g. PharmaLedger<br>    client_id       = string<br>    auth_url        = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize<br>    token_url       = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token<br>    allowed_domains = string # e.g. pharmaledger.org,pharmaledger.eu<br>  })</pre> | `null` | no |
| <a name="input_grafana_ingress_enabled"></a> [grafana\_ingress\_enabled](#input\_grafana\_ingress\_enabled) | Whether to expose Grafana via an ingress to the outside world or not. If 'true' also set valid values for 'grafana\_ingress\_settings' and 'grfana\_ingress\_oidc\_client\_secret' | `bool` | `false` | no |
| <a name="input_grafana_ingress_oidc_client_secret"></a> [grafana\_ingress\_oidc\_client\_secret](#input\_grafana\_ingress\_oidc\_client\_secret) | OIDC Client Secret for AWS ALB | `string` | `null` | no |
| <a name="input_grafana_ingress_settings"></a> [grafana\_ingress\_settings](#input\_grafana\_ingress\_settings) | Settings for configuring AWS ALB via Load Balancer Controller.<br>ingress\_group=name of the ingress group, <br>host\_name=Host name for Grafana, <br>oidc\_enabled=Whether to enable OIDC/OAuth2 at AWS ALB (strongly recommended) or not<br>oidc\_client\_id=The OIDC client ID<br>oidc\_issuer=The issuer of the token, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/v2.0<br>oidc\_authorization\_endpoint=The authz endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize<br>oidc\_token\_endpoint=The token endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token<br>oidc\_user\_info\_endpoint=UserInfo endpoint, e.g. for Azure AD https://graph.microsoft.com/oidc/userinfo | <pre>object({<br>    ingress_group               = string<br>    host_name                   = string<br>    oidc_enabled                = bool<br>    oidc_client_id              = string<br>    oidc_issuer                 = string # e.g. https://login.microsoftonline.com/TENANT_ID/v2.0<br>    oidc_authorization_endpoint = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize<br>    oidc_token_endpoint         = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token<br>    oidc_user_info_endpoint     = string # e.g. https://graph.microsoft.com/oidc/userinfo<br>  })</pre> | `null` | no |
| <a name="input_k8s_dashboard_ingress_enabled"></a> [k8s\_dashboard\_ingress\_enabled](#input\_k8s\_dashboard\_ingress\_enabled) | Whether to expose Kubernetes Dashboard via an ingress to the outside world or not. If 'true' also set valid values for 'k8s\_dashboard\_ingress\_settings' and 'oidc\_client\_secret' | `bool` | `false` | no |
| <a name="input_k8s_dashboard_ingress_oidc_client_secret"></a> [k8s\_dashboard\_ingress\_oidc\_client\_secret](#input\_k8s\_dashboard\_ingress\_oidc\_client\_secret) | OIDC Client Secret for AWS ALB | `string` | `null` | no |
| <a name="input_k8s_dashboard_ingress_settings"></a> [k8s\_dashboard\_ingress\_settings](#input\_k8s\_dashboard\_ingress\_settings) | Settings for configuring AWS ALB via Load Balancer Controller.<br>ingress\_group=name of the ingress group, <br>host\_name=Host name for K8S Dashboard, <br>oidc\_enabled=Whether to enable OIDC/OAuth2 at AWS ALB (strongly recommended) or not<br>oidc\_client\_id=The OIDC client ID<br>oidc\_issuer=The issuer of the token, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/v2.0<br>oidc\_authorization\_endpoint=The authz endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize<br>oidc\_token\_endpoint=The token endpoint, e.g. for Azure AD https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token<br>oidc\_user\_info\_endpoint=UserInfo endpoint, e.g. for Azure AD https://graph.microsoft.com/oidc/userinfo | <pre>object({<br>    ingress_group               = string<br>    host_name                   = string<br>    oidc_enabled                = bool<br>    oidc_client_id              = string<br>    oidc_issuer                 = string # e.g. https://login.microsoftonline.com/TENANT_ID/v2.0<br>    oidc_authorization_endpoint = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/authorize<br>    oidc_token_endpoint         = string # e.g. https://login.microsoftonline.com/TENANT_ID/oauth2/v2.0/token<br>    oidc_user_info_endpoint     = string # e.g. https://graph.microsoft.com/oidc/userinfo<br>  })</pre> | `null` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->