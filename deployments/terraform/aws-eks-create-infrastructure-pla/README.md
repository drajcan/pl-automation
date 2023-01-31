# AWS VPC and EKS Cluster 1.24

## Prerequisites for using terraform

- [terraform - version 1.x - tested with 1.3.6](https://www.terraform.io/downloads.html)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Prerequisites for viewing/monitoring the cluster after creation

- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [kubectl 1.24](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
- [Recommended: K9S](https://k9scli.io/)

## Architecture Overview

![Architecture Overview](docs/architecture_vpc_eks.drawio.png)

## Usage

**Please see [examples folder](./examples/) for complete sample use-cases!**

All examples are almost ready to use, but they are examples! This means, you will have to find the right configuration according to your needs!

## 0. Usage prerequisites

1. [terraform - version 1.x - tested with 1.3.6](https://www.terraform.io/downloads.html)
2. [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. AWS credentials set accordingly to have FullAccess permissions in your AWS account.

### 1. Terraform Providers

You will always need to configure the providers used by Terraform accordingly.
Create a file `providers.tf` and fill with this content (or the content from the examples). Tags and tags to ignore can be set via variable values and are not hard-coded in the `providers.tf` file.

```hcl
provider "aws" {
  region = var.region
  default_tags {
    tags = var.tag_git_repo_url == "" ? var.provider_default_tags : merge({
      "git_repo_url" = var.tag_git_repo_url
    }, var.provider_default_tags)
  }
  ignore_tags {
    keys = var.provider_ignore_tags
  }
}
#
# Kubernetes Provider required in order to maintain authmap
#
provider "kubernetes" {
  host                   = module.cluster.this_eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.this_eks_cluster_certificate_authority_data)
  # Important: We cannot use the token. It seems that the token is being retrieved at terraform plan phase.
  # At plan phase we use a principal with readonly permissions. 
  # This means, any changes at apply phase will be tried with readonly permissions and will fail.
  # Therefore we retrieve a fresh token via aws eks command
  #  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.this_eks_cluster_name, "--region", var.region]
    command     = "aws"
  }
}
```

### 2. Prepare Variables

You should not hard-code any variable values (e.g. stage/environment dependent values) into you terraform files.
First, declare all variables (not the variable values!) in a file named `variables.tf` (also see examples):

```hcl
variable "account_id" {
  type        = string
  description = "The 12 digit account id, e.g. 012345678901."
}
variable "region" {
  type        = string
  description = "The AWS Region"
}
variable "tag_git_repo_url" {
  type        = string
  description = "The URL of the Git repository. If it is a non empty string, it Will be merged into default_tags with key 'git_repo_url'"
  default     = ""
}
variable "provider_default_tags" {
  type        = map(string)
  description = "Default tags for AWS resources"
  default     = {}
}
variable "provider_ignore_tags" {
  type        = list(string)
  description = "A list of tags to ignore for the AWS provider"
  default     = []
}

variable "eks_cluster_name" {
  type        = string
  description = "The Name of the cluster. Will also be used as identifier for multiple resources."
}
variable "eks_aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.4.0#input_aws_auth_roles"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
variable "vpc_single_nat_gateway" {
  type        = bool
  default     = false
  description = "True to deploy only a single NAT Gateway for whole VPC"
}
variable "vpc_one_nat_gateway_per_az" {
  type        = bool
  default     = true
  description = "True to deploy a NAT Gateway for each AZ"
}
variable "vpc_external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = list(string)
  default     = []
}

```

Then create a `.tfvars` file for each stage/environment (here: `dev` and `prod`),

`terraform-dev.tfvars`:

```hcl
account_id            = "123456789012"
region                = "eu-central-1"
eks_cluster_name      = "my-dev-cluster"
provider_default_tags = {
  "CreatedBy" = "PharmaLedger Association"
  "ManagedBy" = "Terraform"
  "Stage"     = "Dev"
}

# Important: Add additional roles for admin privileges in the cluster
eks_aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::123456789012:role/role"
    username = "role"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::123456789012:role/another-role"
    username = "another-role"
    groups   = ["system:masters"]
  }
]

vpc_single_nat_gateway     = true  # Single NAT GW is sufficient for non productive use
vpc_one_nat_gateway_per_az = false # Single NAT GW is sufficient for non productive use
# Your TODO: Create 1 EIP in advance!
vpc_external_nat_ip_ids = ["eipalloc-1234567890abcdef0"]
```

and `terraform-prod.tfvars`:

```hcl
account_id            = "987654321098"
region                = "eu-central-1"
eks_cluster_name      = "my-prod-cluster"
provider_default_tags = {
  "CreatedBy" = "PharmaLedger Association"
  "ManagedBy" = "Terraform"
  "Stage"     = "Prod"
}

# Important: Add additional roles for admin privileges in the cluster
eks_aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::987654321098:role/role"
    username = "role"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::987654321098:role/another-role"
    username = "another-role"
    groups   = ["system:masters"]
  }
]

vpc_single_nat_gateway     = false # Each AZ gets it own NAT GW
vpc_one_nat_gateway_per_az = true  # Each AZ gets it own NAT GW
# Your TODO: Create 3 EIPs in advance - one for each NAT GW in each zone!
vpc_external_nat_ip_ids = ["eipalloc-1234567890abcdef0", "eipalloc-9876543210abcdef0", "eipalloc-6789012345abcdef0"]
```

### 3. Setting up the VPC and cluster

Create file `main.tf` (see [examples/full/main.tf](./examples/full/main.tf)).

Init terraform

```shell
terraform init
```

and install for `dev` environment:

```shell
terraform plan -var-file=terraform-dev.tfvars -state=terraform-dev.tfstate -out=plan-dev.tfplan
terraform apply -input=false -state=terraform-dev.tfstate plan-dev.tfplan
```

and/or for `prod`:

```shell
terraform plan -var-file=terraform-prod.tfvars -state=terraform-prod.tfstate -out=plan-prod.tfplan
terraform apply -input=false -state=terraform-prod.tfstate plan-prod.tfplan
```

**NOTE: Always store your terraform state safely and do not loose it!**
Instead of storing the state locally use the [terraform S3 backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3).

## 4. Connect to Kubernetes Cluster

1. Get the kubeconfig file, [see](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)

  ```bash
  aws eks update-kubeconfig --name my-dev-cluster --kubeconfig ./kubeconfig-dev.yaml
  aws eks update-kubeconfig --name my-prod-cluster --kubeconfig ./kubeconfig-prod.yaml
  ```

2. Use `kubectl` or `k9s` for testing the configuration.

  ```bash
  k9s
  # or use kubectl
  kubectl get pods --all-namespace
  ```

## Contributing

See [here](CONTRIBUTING.md)

Required applications for contributing:

- [pre-commit for terraform](https://github.com/antonbabenko/pre-commit-terraform#1-install-dependencies) with these additional tools (see file `.pre-commit-config.yaml`)
  - terraform-docs
  - TFLint

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).
Follow [these instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) to install pre-commit locally and install `terraform-docs` either via download from [github.com](https://github.com/terraform-docs/terraform-docs/releases) or via package managers `go get github.com/segmentio/terraform-docs` or `brew install terraform-docs`.

1. Pay attention that a `README.md` file **must be utf-8 encoded**!
2. Does not work on Windows, use Linux or Mac instead!

## Authors

Created by

- [tgip-work](https://github.com/tgip-work)

## Terraform Module Details

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.4.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.18.1 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 3.18.1 |

### Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag) | resource |
| [aws_cloudwatch_log_group.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_flow_log.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.vpc_flow_log_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy_document.vpc_flow_log_cloudwatch_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_log_cloudwatch_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc_flow_log_cloudwatch_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.aws_ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | Must be exactly two, three or four availability zones, e.g. eu-central-1a, eu-central-1b, eu-central-1c | `list(string)` | n/a | yes |
| <a name="input_eks_aws_auth_accounts"></a> [eks\_aws\_auth\_accounts](#input\_eks\_aws\_auth\_accounts) | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_eks_aws_auth_roles"></a> [eks\_aws\_auth\_roles](#input\_eks\_aws\_auth\_roles) | Additional IAM roles to add to the aws-auth configmap. See https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.4.0#input_aws_auth_roles | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_aws_auth_users"></a> [eks\_aws\_auth\_users](#input\_eks\_aws\_auth\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_cloudwatch_log_group_retention_in_days"></a> [eks\_cloudwatch\_log\_group\_retention\_in\_days](#input\_eks\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain cluster log events | `number` | `30` | no |
| <a name="input_eks_cluster_enabled_log_types"></a> [eks\_cluster\_enabled\_log\_types](#input\_eks\_cluster\_enabled\_log\_types) | List of enabled log types | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator"<br>]</pre> | no |
| <a name="input_eks_cluster_endpoint_public_access_cidrs"></a> [eks\_cluster\_endpoint\_public\_access\_cidrs](#input\_eks\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | n/a | `string` | `"1.24"` | no |
| <a name="input_eks_enable_irsa"></a> [eks\_enable\_irsa](#input\_eks\_enable\_irsa) | Whether to create OpenID Connect Provider for EKS to enable IRSA | `bool` | `true` | no |
| <a name="input_eks_fargate_profiles"></a> [eks\_fargate\_profiles](#input\_eks\_fargate\_profiles) | Fargate Profiles | `map(any)` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of map of node groups to create. - see https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v18.30.2/modules/eks-managed-node-group for details. Please note: For Cluster Autoscaler to work properly an AutoScalingGroup (ASG) must be bound to exactly one availability zone (AZ)! Therefore a single node group shall not use more than one subnet/AZ. | `any` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR range for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_create_database_internet_gateway_route"></a> [vpc\_create\_database\_internet\_gateway\_route](#input\_vpc\_create\_database\_internet\_gateway\_route) | Controls if an internet gateway route for public database access should be created | `bool` | `false` | no |
| <a name="input_vpc_create_database_subnets"></a> [vpc\_create\_database\_subnets](#input\_vpc\_create\_database\_subnets) | Whether to create intra database or not | `bool` | `false` | no |
| <a name="input_vpc_create_intra_subnets"></a> [vpc\_create\_intra\_subnets](#input\_vpc\_create\_intra\_subnets) | Whether to create intra subnets or not | `bool` | `false` | no |
| <a name="input_vpc_database_subnets"></a> [vpc\_database\_subnets](#input\_vpc\_database\_subnets) | CIDR ranges for the database subnets; by default 1019 IPv4 addresses per subnet. If vpc\_azs contains three values, then the first 3 subnets will be used. | `list(string)` | <pre>[<br>  "10.0.80.0/22",<br>  "10.0.84.0/22",<br>  "10.0.88.0/22",<br>  "10.0.92.0/22"<br>]</pre> | no |
| <a name="input_vpc_enable_flow_log_cloudwatch"></a> [vpc\_enable\_flow\_log\_cloudwatch](#input\_vpc\_enable\_flow\_log\_cloudwatch) | Boolean if VPC Flow log to Cloudwatch will be created | `bool` | `true` | no |
| <a name="input_vpc_external_nat_ip_ids"></a> [vpc\_external\_nat\_ip\_ids](#input\_vpc\_external\_nat\_ip\_ids) | List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse\_nat\_ips) | `list(string)` | `[]` | no |
| <a name="input_vpc_flow_log_cloudwatch_retention_in_days"></a> [vpc\_flow\_log\_cloudwatch\_retention\_in\_days](#input\_vpc\_flow\_log\_cloudwatch\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `30` | no |
| <a name="input_vpc_intra_subnets"></a> [vpc\_intra\_subnets](#input\_vpc\_intra\_subnets) | CIDR ranges for the intra subnets; by default 1019 IPv4 addresses per subnet. If vpc\_azs contains three values, then the first 3 subnets will be used. | `list(string)` | <pre>[<br>  "10.0.96.0/22",<br>  "10.0.100.0/22",<br>  "10.0.104.0/22",<br>  "10.0.108.0/22"<br>]</pre> | no |
| <a name="input_vpc_one_nat_gateway_per_az"></a> [vpc\_one\_nat\_gateway\_per\_az](#input\_vpc\_one\_nat\_gateway\_per\_az) | True to deploy a NAT Gateway for each AZ | `bool` | `true` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | CIDR ranges for the private subnets; by default 4091 IPv4 addresses per subnet. If vpc\_azs contains three values, then the first 3 subnets will be used. | `list(string)` | <pre>[<br>  "10.0.16.0/20",<br>  "10.0.32.0/20",<br>  "10.0.48.0/20",<br>  "10.0.64.0/20"<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | CIDR ranges for the public subnets; by default 1019 IPv4 addresses per subnet. If vpc\_azs contains three values, then the first 3 subnets will be used. | `list(string)` | <pre>[<br>  "10.0.0.0/22",<br>  "10.0.4.0/22",<br>  "10.0.8.0/22",<br>  "10.0.12.0/22"<br>]</pre> | no |
| <a name="input_vpc_reuse_nat_ips"></a> [vpc\_reuse\_nat\_ips](#input\_vpc\_reuse\_nat\_ips) | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external\_nat\_ip\_ids' variable | `bool` | `false` | no |
| <a name="input_vpc_single_nat_gateway"></a> [vpc\_single\_nat\_gateway](#input\_vpc\_single\_nat\_gateway) | True to deploy only a single NAT Gateway for whole VPC | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_default_aws_ebs_kms_key_arn"></a> [this\_default\_aws\_ebs\_kms\_key\_arn](#output\_this\_default\_aws\_ebs\_kms\_key\_arn) | ARN of the default AWS EBS KMS Key |
| <a name="output_this_eks_cluster_certificate_authority_data"></a> [this\_eks\_cluster\_certificate\_authority\_data](#output\_this\_eks\_cluster\_certificate\_authority\_data) | The CA (certificate authority) of the EKS Cluster |
| <a name="output_this_eks_cluster_endpoint"></a> [this\_eks\_cluster\_endpoint](#output\_this\_eks\_cluster\_endpoint) | The Endpoint of the EKS Cluster |
| <a name="output_this_eks_cluster_name"></a> [this\_eks\_cluster\_name](#output\_this\_eks\_cluster\_name) | The ID/Name of the EKS Cluster |
| <a name="output_this_module_eks"></a> [this\_module\_eks](#output\_this\_module\_eks) | All outputs from EKS module - see https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/18.30.2?tab=outputs |
| <a name="output_this_module_vpc"></a> [this\_module\_vpc](#output\_this\_module\_vpc) | All outputs from VPC module - see https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.18.1?tab=outputs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->