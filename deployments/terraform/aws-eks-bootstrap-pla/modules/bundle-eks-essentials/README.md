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

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_fluent_bit"></a> [aws\_fluent\_bit](#module\_aws\_fluent\_bit) | ./modules/aws-fluent-bit | n/a |
| <a name="module_aws_loadbalancer_controller"></a> [aws\_loadbalancer\_controller](#module\_aws\_loadbalancer\_controller) | ./modules/aws-loadbalancer-controller | n/a |
| <a name="module_calico_tigera_operator"></a> [calico\_tigera\_operator](#module\_calico\_tigera\_operator) | ./modules/calico-tigera-operator | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./modules/cluster-autoscaler | n/a |
| <a name="module_cluster_role_cluster_view"></a> [cluster\_role\_cluster\_view](#module\_cluster\_role\_cluster\_view) | ./modules/cluster-role-cluster-view | n/a |
| <a name="module_default_clusterrolebindings"></a> [default\_clusterrolebindings](#module\_default\_clusterrolebindings) | ./modules/default-clusterrolebindings | n/a |
| <a name="module_external_dns"></a> [external\_dns](#module\_external\_dns) | ./modules/external-dns | n/a |
| <a name="module_ingress_groups_defaults"></a> [ingress\_groups\_defaults](#module\_ingress\_groups\_defaults) | ./modules/ingress-groups-defaults | n/a |
| <a name="module_metrics_server"></a> [metrics\_server](#module\_metrics\_server) | ./modules/metrics-server | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The 12 digit account id, e.g. 012345678901. | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The Name/ID of the EKS Cluster. | `string` | n/a | yes |
| <a name="input_ingress_groups"></a> [ingress\_groups](#input\_ingress\_groups) | Default ingress settings implemented as Kubernetes ingress. Key is the groupName. Contains redirect from port 80 to 443, logging settings, SSL certificate, optional WAF v2 ACL attachment.<br>certificate\_arn=Specifies the ARN of one or more certificate managed by AWS Certificate Manager; can be a single ARN or a list of ARNs seperated by comma.<br>idle\_timeout\_seconds=The idle timeout.<br>deletion\_protection\_enabled=Whether to enable deletion protection of the ALB or not.<br>wafv2\_acl\_arn=Specifies ARN for the Amazon WAFv2 web ACL. Can be null to not use a WAF.<br>shield\_advanced\_protection=turns on / off the AWS Shield Advanced protection for the load balancer.<br>s3\_logging\_enabled=Whether to enabled logging to S3 or not.<br>s3\_logging\_bucket\_name=Name of the S3 bucket used for logging.<br>s3\_logging\_prefix=String literal used as prefix, e.g. my-app | <pre>map(object({<br>    certificate_arn             = string<br>    idle_timeout_seconds        = number<br>    deletion_protection_enabled = bool<br>    wafv2_acl_arn               = string<br>    shield_advanced_protection  = bool<br>    s3_logging_enabled          = bool<br>    s3_logging_bucket_name      = string<br>    s3_logging_prefix           = string<br>  }))</pre> | n/a | yes |
| <a name="input_kubeconfig_filename"></a> [kubeconfig\_filename](#input\_kubeconfig\_filename) | Path to Kubeconfig file | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL of the AWS OIDC Provider associated with the EKS cluster | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region of the EKS cluster. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC | `string` | n/a | yes |
| <a name="input_calico_install_flag"></a> [calico\_install\_flag](#input\_calico\_install\_flag) | Whether to install Calico or not. | `bool` | `false` | no |
| <a name="input_clusterrole_cluster_view_rules"></a> [clusterrole\_cluster\_view\_rules](#input\_clusterrole\_cluster\_view\_rules) | Additional rules for clusterrole cluster-view added to rules from default clusterrole view | <pre>list(object({<br>    api_groups = list(string)<br>    resources  = list(string)<br>    verbs      = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "api_groups": [<br>      ""<br>    ],<br>    "resources": [<br>      "secrets"<br>    ],<br>    "verbs": [<br>      "list"<br>    ]<br>  },<br>  {<br>    "api_groups": [<br>      "rbac.authorization.k8s.io"<br>    ],<br>    "resources": [<br>      "clusterroles",<br>      "clusterrolebindings",<br>      "rolebindings",<br>      "roles"<br>    ],<br>    "verbs": [<br>      "list",<br>      "get"<br>    ]<br>  },<br>  {<br>    "api_groups": [<br>      "apiextensions.k8s.io"<br>    ],<br>    "resources": [<br>      "customresourcedefinitions"<br>    ],<br>    "verbs": [<br>      "list"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_create_clusterrole_cluster_view"></a> [create\_clusterrole\_cluster\_view](#input\_create\_clusterrole\_cluster\_view) | Whether to create clusterrole cluster-view with same rules as default clusterrole view and further rules (see clusterrole\_cluster\_view\_rules) or not. | `bool` | `true` | no |
| <a name="input_extra_assume_role_policy_statements"></a> [extra\_assume\_role\_policy\_statements](#input\_extra\_assume\_role\_policy\_statements) | A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy. | `list(any)` | `[]` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->