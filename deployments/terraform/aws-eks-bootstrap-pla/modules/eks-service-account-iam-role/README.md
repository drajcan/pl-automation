# aws-eks-service-account-iam-role

Creates an AWS IAM role and configures it to be used by an Kubernetes Service Account in EKS. See [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html) for details.

## Usage

Sample for external-dns:

```hcl
module "iam_role" {
  source = "../../../eks-service-account-iam-role"

  account_id        = var.account_id
  oidc_provider_url = var.oidc_provider_url
  name              = "${var.eks_cluster_name}-external-dns"
  service_accounts  = ["kube-system/external-dns"]
  inline_policies = [<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
  ]
}

```

## Terraform Module Details

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.43, < 5.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.43, < 5.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | ID of the AWS account | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM role. | `string` | n/a | yes |
| <a name="input_oidc_provider_url"></a> [oidc\_provider\_url](#input\_oidc\_provider\_url) | URL of the AWS OIDC Provider associated with the EKS cluster | `string` | n/a | yes |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | List of Kubernetes service accounts (in the format namespace/serviceaccount) that are trusted to assume this role. Can also be namespace/* | `list(string)` | n/a | yes |
| <a name="input_extra_assume_role_policy_statements"></a> [extra\_assume\_role\_policy\_statements](#input\_extra\_assume\_role\_policy\_statements) | A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy. | `list(any)` | `[]` | no |
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | A list of policies in JSON format which will be attached to the IAM role as inline-policies. | `list(string)` | `[]` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A list of existing IAM policy ARNs which will be attached to the IAM role. | `list(string)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_role_arn"></a> [this\_role\_arn](#output\_this\_role\_arn) | The ARN of the IAM role |
| <a name="output_this_role_name"></a> [this\_role\_name](#output\_this\_role\_name) | The name of the IAM role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->