# aws-eks-managed-addons

Turn the addons installed by default on a "fresh" AWS EKS cluster into EKS-managed add-ons.

- kube-proxy
- coredns
- vpc-cni (aka aws-node)

## Usage

```hcl
module "eks_managed_addons" {
  source = "./modules/aws-eks-managed-addons"

  account_id                               = var.account_id
  eks_cluster_name                         = module.eks.cluster_id
  oidc_provider_url                        = module.eks.cluster_oidc_issuer_url
  kubeconfig_filename                      = module.eks.kubeconfig_filename

  depends_on = [module.eks]
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
| <a name="module_coredns"></a> [coredns](#module\_coredns) | ./modules/coredns | n/a |
| <a name="module_kube_proxy"></a> [kube\_proxy](#module\_kube\_proxy) | ./modules/kube-proxy | n/a |
| <a name="module_vpc_cni"></a> [vpc\_cni](#module\_vpc\_cni) | ./modules/vpc-cni | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The 12 digit account id, e.g. 012345678901. | `string` | n/a | yes |
| <a name="input_coredns_version"></a> [coredns\_version](#input\_coredns\_version) | The version of the managed Add-On coredns - Either 'latest', 'default' or a specific version 'v1.8.7-eksbuild.2'. | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The Name/ID of the EKS Cluster. | `string` | n/a | yes |
| <a name="input_kube_proxy_version"></a> [kube\_proxy\_version](#input\_kube\_proxy\_version) | The version of the managed Add-On kube-proxy - Either 'latest', 'default' or a specific version 'v1.22.11-eksbuild.2'. | `string` | n/a | yes |
| <a name="input_kubeconfig_filename"></a> [kubeconfig\_filename](#input\_kubeconfig\_filename) | Path to Kubeconfig file | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL of the AWS OIDC Provider associated with the EKS cluster | `string` | n/a | yes |
| <a name="input_vpc_cni_version"></a> [vpc\_cni\_version](#input\_vpc\_cni\_version) | The version of the managed Add-On vpc-cni - Either 'latest', 'default' or a specific version 'v1.11.4-eksbuild.1'. | `string` | n/a | yes |
| <a name="input_extra_assume_role_policy_statements"></a> [extra\_assume\_role\_policy\_statements](#input\_extra\_assume\_role\_policy\_statements) | A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy. | `list(any)` | `[]` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->