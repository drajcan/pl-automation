# Sample for non production environment
# All three availability zones (AZs) share a single NAT gateway in order to save money.

account_id = "123456789012"
region     = "eu-central-1"
provider_default_tags = {
  "CreatedBy"          = "PharmaLedger Association"
  "ManagedBy"          = "Terraform"
  "Project"            = "PharmaLedger"
  "TechnicalContact_1" = "firstname1.lastname1@pharmaledger.org"
  "TechnicalContact_2" = "firstname2.lastname2@pharmaledger.org"
}
provider_ignore_tags = ["ignore-this-tag"]

eks_cluster_name = "pla-test"
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
# Your TODO: Create an EIP in advance!
vpc_external_nat_ip_ids = ["eipalloc-1234567890abcdef0"]