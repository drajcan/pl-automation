locals {
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
  aws_loadbalancer_account_id_by_region = {
    us-east-1    = "127311923021"
    us-east-2    = "033677994240"
    eu-west-1    = "156460612806"
    eu-north-1   = "897822967062"
    eu-central-1 = "054676820928"
  }
}
