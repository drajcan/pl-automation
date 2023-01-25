# 
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.18.1
#
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"
  name    = "${var.eks_cluster_name}-vpc"

  #
  # Subnet settings - we use two, three or four AZs for HA
  #
  azs  = var.vpc_azs
  cidr = var.vpc_cidr

  # Public subnet settings
  public_subnets = slice(var.vpc_public_subnets, 0, length(var.vpc_azs))
  public_subnet_tags = {
    Tier                                            = "public"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }
  public_subnet_suffix = "public"

  # Intra Subnets (no route to NAT GW) for internal LoadBalancers which shall only be reachable from API GW VPC Links
  intra_subnets = var.vpc_create_intra_subnets ? slice(var.vpc_intra_subnets, 0, length(var.vpc_azs)) : []
  intra_subnet_tags = {
    Tier = "intra"
  }
  intra_subnet_suffix = "intra"

  # Private subnet settings
  private_subnets = slice(var.vpc_private_subnets, 0, length(var.vpc_azs))
  private_subnet_tags = {
    Tier                                            = "private"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
  private_subnet_suffix = "private"

  # Database subnet settings
  database_subnets = var.vpc_create_database_subnets ? slice(var.vpc_database_subnets, 0, length(var.vpc_azs)) : []
  database_subnet_tags = {
    Tier = "db"
  }
  database_subnet_suffix = "db"

  # NAT GW Settings
  enable_nat_gateway     = true
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
  reuse_nat_ips          = var.vpc_reuse_nat_ips
  external_nat_ip_ids    = var.vpc_external_nat_ip_ids

  # VPN Settings
  enable_vpn_gateway = false

  # create_database_nat_gateway_route = true 
  create_database_subnet_group           = true                                           # DO NOT DELETE! Controls if database subnet group should be created
  create_database_subnet_route_table     = true                                           # DO NOT DELETE! Controls if separate route table for database should be created
  create_database_internet_gateway_route = var.vpc_create_database_internet_gateway_route # Controls if an internet gateway route for public database access should be created

  # EC2 related settings
  enable_dns_hostnames     = true
  enable_dhcp_options      = true
  dhcp_options_ntp_servers = ["169.254.169.123"]
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.18.1"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags = {
        Name = "${var.eks_cluster_name}-vpc-s3"
      }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      tags = {
        Name = "${var.eks_cluster_name}-vpc-dynamodb"
      }
    }
  }
}
