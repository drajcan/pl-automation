# 1. Two workernodes in two different AZs - this is necessary for the bootstrapping process (later on) to distribute pod replicas across different nodes in different zones.
# 2. No workernode runs in third AZ on startup - let Cluster Autoscaler decide on further scale-outs and scale-ins

module "cluster" {
  # IMPORTANT: The source can be either
  # a) a copy of this repository into your own repo (local copy), e.g. to `modules/aws-eks-infrastructure` - `source = "./modules/aws-eks-infrastructure"`
  # b) a copy of this repository into a dedicated repo of your choice. See https://developer.hashicorp.com/terraform/language/modules/sources for configuring the module source.
  source = "../" # for the example, we reference the module in this repo

  eks_cluster_name                          = var.eks_cluster_name
  account_id                                = var.account_id
  vpc_azs                                   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  vpc_single_nat_gateway                    = var.vpc_single_nat_gateway
  vpc_one_nat_gateway_per_az                = var.vpc_one_nat_gateway_per_az
  vpc_enable_flow_log_cloudwatch            = true
  vpc_flow_log_cloudwatch_retention_in_days = 30
  vpc_reuse_nat_ips                         = true                        # We provide ElasticIP for each NAT GW
  vpc_external_nat_ip_ids                   = var.vpc_external_nat_ip_ids # The ElasticIPs for the NAT GWs
  eks_aws_auth_roles                        = var.eks_aws_auth_roles
  eks_aws_auth_users                        = var.eks_aws_auth_users

  # See https://github.com/terraform-aws-modules/terraform-aws-eks/tree/v18.30.2/modules/node_groups
  # https://eksctl.io/usage/autoscaling/#zone-aware-auto-scaling
  # https://aws.amazon.com/blogs/containers/amazon-eks-cluster-multi-zone-auto-scaling-groups/
  eks_managed_node_groups = {
    default-1a = {
      min_size     = 1
      max_size     = 2
      desired_size = 1 # Initial value: After creation will not be changed via terraform. See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#why-are-there-no-changes-when-a-node-groups-desired_size-is-modified

      instance_types = ["t3.xlarge"]
      subnet_ids     = [module.cluster.this_module_vpc.private_subnets[0]]
      # Additional tags to help Cluster Autoscaler determine which node group to de/increase depending on a specific zone
      # Note: failure-domain.beta.kubernetes.io is deprecated since 1.17 and topology.kubernetes.io should be used now
      # See https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md 
      # and https://github.com/kubernetes/autoscaler/issues/3194
      # and https://aws.amazon.com/blogs/containers/amazon-eks-cluster-multi-zone-auto-scaling-groups/
      tags = {
        "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/region" = var.region
        "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/region"            = var.region
        "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/zone"   = "${var.region}a"
        "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/zone"              = "${var.region}a"
        "Name"                                                                                   = "${var.eks_cluster_name}-${var.region}a"
      }

      # https://aws.github.io/aws-eks-best-practices/security/docs/iam/#restrict-access-to-the-instance-profile-assigned-to-the-worker-node
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            # Root Disk Encryption with default AWS/EBS Key
            encrypted   = true
            kms_key_id  = module.cluster.this_default_aws_ebs_kms_key_arn
            volume_size = 100
            volume_type = "gp3"
          }
        }
      }
    }
    default-1b = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.xlarge"]
      subnet_ids     = [module.cluster.this_module_vpc.private_subnets[1]]
      tags = {
        "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/region" = var.region
        "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/region"            = var.region
        "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/zone"   = "${var.region}b"
        "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/zone"              = "${var.region}b"
        "Name"                                                                                   = "${var.eks_cluster_name}-${var.region}b"
      }

      # https://aws.github.io/aws-eks-best-practices/security/docs/iam/#restrict-access-to-the-instance-profile-assigned-to-the-worker-node
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            kms_key_id            = module.cluster.this_default_aws_ebs_kms_key_arn
            volume_size           = 100
            volume_type           = "gp3"
          }
        }
      }
    }
    default-1c = {
      min_size     = 0
      max_size     = 2
      desired_size = 0

      instance_types = ["t3.xlarge"]
      subnet_ids     = [module.cluster.this_module_vpc.private_subnets[2]]
      tags = {
        "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/region" = var.region
        "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/region"            = var.region
        "k8s.io/cluster-autoscaler/node-template/label/failure-domain.beta.kubernetes.io/zone"   = "${var.region}c"
        "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/zone"              = "${var.region}c"
        "Name"                                                                                   = "${var.eks_cluster_name}-${var.region}c"
      }

      # https://aws.github.io/aws-eks-best-practices/security/docs/iam/#restrict-access-to-the-instance-profile-assigned-to-the-worker-node
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            kms_key_id            = module.cluster.this_default_aws_ebs_kms_key_arn
            volume_size           = 100
            volume_type           = "gp3"
          }
        }
      }
    }
  }
}
