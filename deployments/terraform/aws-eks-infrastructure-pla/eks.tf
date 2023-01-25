#
# The EKS Cluster
#

# KMS Key for encrypting EKS Cluster config
resource "aws_kms_key" "eks" {
  description             = "EKS Cluster ${var.eks_cluster_name} Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
resource "aws_kms_alias" "eks" {
  name          = "alias/eks/${var.eks_cluster_name}"
  target_key_id = aws_kms_key.eks.key_id
}

# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.4.0
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.4.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_enabled_log_types              = var.eks_cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.eks_cloudwatch_log_group_retention_in_days
  cluster_endpoint_private_access        = false
  cluster_endpoint_public_access         = true
  cluster_endpoint_public_access_cidrs   = var.eks_cluster_endpoint_public_access_cidrs

  # Important change for terraform-aws-eks to v18:
  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-18.0.md
  # >> Security group usage has been overhauled to provide only the bare minimum network connectivity required to launch a bare bones cluster.
  # 
  # Therefore we allow all communication between nodes and allow all outgoing traffic
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/network_connectivity.md
  # node_security_group_additional_rules = {
  #   ingress_self_all = {
  #     description = "Node to node all ports/protocols"
  #     protocol    = "-1"
  #     from_port   = 0
  #     to_port     = 0
  #     type        = "ingress"
  #     self        = true
  #   }
  #   ingress_controlplane_all = {
  #     description = "Allow workers pods to receive communication from the cluster control plane."
  #     protocol    = "TCP"
  #     from_port   = 1025
  #     to_port     = 65535
  #     type        = "ingress"
  #     source_cluster_security_group = true
  #   }
  #   egress_all = {
  #     description      = "Node all egress"
  #     protocol         = "-1"
  #     from_port        = 0
  #     to_port          = 0
  #     type             = "egress"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #   }
  # }

  # Enable IAM Roles for Service Accounts - this creates an OIDC Provider
  enable_irsa = var.eks_enable_irsa

  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  # By default we do not attach AWS managed policy 'AmazonEKS_CNI_Policy' to workers IAM role as
  # the bootstrapping of the EKS cluster attaches an IAM role at the service account of the daemonset 'aws-node'.
  # By doing so, we remove permissions from the node (least privilege).
  # https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
  #attach_worker_cni_policy = var.eks_attach_worker_cni_policy
  fargate_profiles = var.eks_fargate_profiles

  # aws-auth configmap
  manage_aws_auth_configmap = true
  aws_auth_roles            = var.eks_aws_auth_roles
  aws_auth_users            = var.eks_aws_auth_users
  aws_auth_accounts         = var.eks_aws_auth_accounts

  # Nodegroups
  eks_managed_node_groups = var.eks_managed_node_groups
}

#
# IMPORTANT: The ASGs created by Node Groups are not tagged appropriate so that Cluster Autoscaler can autodetect Kubernetes Labels at ASGs
# See https://github.com/aws/containers-roadmap/issues/608
#
# Terraform provider 3.56.0 or higher required: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group_tag
resource "aws_autoscaling_group_tag" "eks" {
  depends_on = [
    module.eks
  ]
  for_each = {
    for each_asg_tag in flatten([
      for each_ng in local.node_groups_autoscaling_tags : [
        for each_tag_key, each_tag_value in each_ng.tags :
        {
          # create a key from node_group + tag_key
          unique_key             = "${each_ng.node_group_key}_${each_tag_key}"
          node_group             = each_ng.node_group_key
          autoscaling_group_name = each_ng.autoscaling_groups[0] # We only use the first and only ASG instead of iterating over all (unknown number of ASGs)
          tag_key                = each_tag_key
          tag_value              = each_tag_value
        }
      ]
    ]) : each_asg_tag.unique_key => each_asg_tag
  }

  #
  # Iterating over all ASGs of a node group does NOT work.
  # Terraform complains with "The "for_each" value depends on resource attributes that cannot be determined until apply"
  # The reason is that TF does not known during plan phase how many ASGs will be created!
  #
  # for_each = {
  #   for each_asg_tag in flatten([
  #     for each_ng in local.node_groups_autoscaling_tags : [
  #       for each_asg_k, each_asg_v in each_ng.autoscaling_groups : [
  #         for each_tag_key, each_tag_value in each_ng.tags :
  #         {
  #           # create a key from node_group + asg + tag
  #           unique_key             = "${each_ng.node_group_key}_${each_asg_k}_${each_tag_key}"
  #           node_group             = each_ng.node_group_key
  #           autoscaling_group_name = each_asg_v.name
  #           tag_key                = each_tag_key
  #           tag_value              = each_tag_value
  #         }
  #       ]
  #     ]
  #   ]) : "${each_asg_tag.unique_key}" => each_asg_tag
  # }

  autoscaling_group_name = each.value.autoscaling_group_name

  tag {
    key   = each.value.tag_key
    value = each.value.tag_value

    propagate_at_launch = true
  }
}