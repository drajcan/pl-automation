locals {
  oidc_issuer_path = replace(var.oidc_provider_url, "https://", "")
  flatList         = join(",", var.service_accounts)
  replacedList = replace(
    replace(local.flatList, "/", ":"),
    "system:serviceaccount:",
    "",
  )
  serviceAccountList = formatlist("system:serviceaccount:%s", split(",", local.replacedList))

  # We build the IAM trust relationship manually (including the concat!) in order to see changes at terraform plan phase
  # Also see https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/
  assume_role_policy = jsonencode({
    Statement = concat([
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "${local.oidc_issuer_path}:sub" = local.serviceAccountList
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${local.oidc_issuer_path}"
        }
        Sid = "AssumeableByOIDC"
      }
    ], var.extra_assume_role_policy_statements),
    Version = "2012-10-17"
  })
}
