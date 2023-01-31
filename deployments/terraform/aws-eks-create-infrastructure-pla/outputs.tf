output "this_default_aws_ebs_kms_key_arn" {
  description = "ARN of the default AWS EBS KMS Key"
  value       = data.aws_kms_key.aws_ebs.arn
}
output "this_eks_cluster_name" {
  description = "The ID/Name of the EKS Cluster"
  value       = module.eks.cluster_name
}
output "this_eks_cluster_endpoint" {
  description = "The Endpoint of the EKS Cluster"
  value       = module.eks.cluster_endpoint
}
output "this_eks_cluster_certificate_authority_data" {
  description = "The CA (certificate authority) of the EKS Cluster"
  value       = module.eks.cluster_certificate_authority_data
}
output "this_module_eks" {
  description = "All outputs from EKS module - see https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/18.30.2?tab=outputs"
  value       = module.eks
}
output "this_module_vpc" {
  description = "All outputs from VPC module - see https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.18.1?tab=outputs"
  value       = module.vpc
}