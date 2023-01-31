# Sample for non production environment
# All three availability zones (AZs) share a single NAT gateway in order to save money.

account_id = "783506966386"
region     = "eu-central-1"
provider_default_tags = {
  "CreatedBy"          = "PharmaLedger Association"
  "ManagedBy"          = "Terraform"
  "Project"            = "PharmaLedger"
  "TechnicalContact_1" = "firstname1.lastname1@pharmaledger.org"
  "TechnicalContact_2" = "firstname2.lastname2@pharmaledger.org"
}
provider_ignore_tags = ["ignore-this-tag"]

eks_cluster_name = "cluster-100"
eks_aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::783506966386:role/plaDemoEKSNodeRole"
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:masters", "system:nodes"]
  }
]

vpc_single_nat_gateway     = true  # Single NAT GW is sufficient for non productive use
vpc_one_nat_gateway_per_az = false # Single NAT GW is sufficient for non productive use
# Your TODO: Create an EIP in advance!
vpc_external_nat_ip_ids = ["eipalloc-0da9cc9a34daffa7e"]