# kubeconfig

Creates the config file for kubectl as `aws eks `
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 5.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.2.3 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0, < 5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.2.3 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [local_file.main](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_eks_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region, e.g. eu-central-1 | `string` | n/a | yes |
| <a name="input_kubeconfig_auth_additional_args"></a> [kubeconfig\_auth\_additional\_args](#input\_kubeconfig\_auth\_additional\_args) | Any additional arguments to pass on authenticating such as the role to assume. e.g. ["-r", "MyEksRole"]. | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_auth_api_version"></a> [kubeconfig\_auth\_api\_version](#input\_kubeconfig\_auth\_api\_version) | API version for authentication in kubeconfig | `string` | `"client.authentication.k8s.io/v1beta1"` | no |
| <a name="input_kubeconfig_auth_command"></a> [kubeconfig\_auth\_command](#input\_kubeconfig\_auth\_command) | Command to use to fetch AWS EKS credentials. | `string` | `"aws"` | no |
| <a name="input_kubeconfig_auth_command_args"></a> [kubeconfig\_auth\_command\_args](#input\_kubeconfig\_auth\_command\_args) | Default arguments passed on authenticating. Defaults to [--region $region eks get-token --cluster-name $cluster\_name]. | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_auth_env_variables"></a> [kubeconfig\_auth\_env\_variables](#input\_kubeconfig\_auth\_env\_variables) | Environment variables that should be used on authenticating. e.g. { AWS\_PROFILE = "eks"}. | `map(string)` | `{}` | no |
| <a name="input_kubeconfig_file_permission"></a> [kubeconfig\_file\_permission](#input\_kubeconfig\_file\_permission) | File permission of the Kubectl config file containing cluster configuration saved to `kubeconfig_output_path.` | `string` | `"0600"` | no |
| <a name="input_kubeconfig_output_path"></a> [kubeconfig\_output\_path](#input\_kubeconfig\_output\_path) | Where to save the Kubectl config file. Assumed to be a directory if the value ends with a forward slash `/`. | `string` | `"./"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_kubeconfig_filename"></a> [this\_kubeconfig\_filename](#output\_this\_kubeconfig\_filename) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->