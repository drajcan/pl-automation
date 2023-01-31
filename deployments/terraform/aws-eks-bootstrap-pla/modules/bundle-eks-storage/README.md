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
| <a name="module_aws_csi_secrets_store_provider"></a> [aws\_csi\_secrets\_store\_provider](#module\_aws\_csi\_secrets\_store\_provider) | ./modules/aws-csi-secrets-store-provider | n/a |
| <a name="module_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#module\_aws\_ebs\_csi\_driver) | ./modules/aws-ebs-csi-driver | n/a |
| <a name="module_aws_efs_csi_driver"></a> [aws\_efs\_csi\_driver](#module\_aws\_efs\_csi\_driver) | ./modules/aws-efs-csi-driver | n/a |
| <a name="module_csi_external_snapshotter"></a> [csi\_external\_snapshotter](#module\_csi\_external\_snapshotter) | ./modules/csi-external-snapshotter | n/a |
| <a name="module_csi_secrets_store_driver"></a> [csi\_secrets\_store\_driver](#module\_csi\_secrets\_store\_driver) | ./modules/csi-secrets-store-driver | n/a |
| <a name="module_snapscheduler"></a> [snapscheduler](#module\_snapscheduler) | ./modules/snapscheduler | n/a |
| <a name="module_storageclass_gp2_encrypted"></a> [storageclass\_gp2\_encrypted](#module\_storageclass\_gp2\_encrypted) | ./modules/storageclass-gp2-encrypted | n/a |
| <a name="module_storageclass_gp3_encrypted"></a> [storageclass\_gp3\_encrypted](#module\_storageclass\_gp3\_encrypted) | ./modules/storageclass-gp3-encrypted | n/a |
| <a name="module_volumesnapshotclass_csi_aws"></a> [volumesnapshotclass\_csi\_aws](#module\_volumesnapshotclass\_csi\_aws) | ./modules/volumesnapshotclass-csi-aws | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The 12 digit account id, e.g. 012345678901. | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The Name/ID of the EKS Cluster. | `string` | n/a | yes |
| <a name="input_kubeconfig_filename"></a> [kubeconfig\_filename](#input\_kubeconfig\_filename) | Path to Kubeconfig file | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL of the AWS OIDC Provider associated with the EKS cluster | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region of the EKS cluster. | `string` | n/a | yes |
| <a name="input_extra_assume_role_policy_statements"></a> [extra\_assume\_role\_policy\_statements](#input\_extra\_assume\_role\_policy\_statements) | A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy. | `list(any)` | `[]` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->