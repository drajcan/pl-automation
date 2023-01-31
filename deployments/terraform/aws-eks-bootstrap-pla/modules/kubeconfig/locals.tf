locals {
  kubeconfig_name = "eks_${var.eks_cluster_name}"

  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name                 = local.kubeconfig_name
    arn                             = data.aws_eks_cluster.main.arn
    endpoint                        = data.aws_eks_cluster.main.endpoint
    cluster_auth_base64             = data.aws_eks_cluster.main.certificate_authority[0].data
    kubeconfig_auth_api_version     = var.kubeconfig_auth_api_version
    kubeconfig_auth_command         = var.kubeconfig_auth_command
    kubeconfig_auth_command_args    = length(var.kubeconfig_auth_command_args) > 0 ? var.kubeconfig_auth_command_args : ["--region", var.region, "eks", "get-token", "--cluster-name", data.aws_eks_cluster.main.id]
    kubeconfig_auth_additional_args = var.kubeconfig_auth_additional_args
    kubeconfig_auth_env_variables   = var.kubeconfig_auth_env_variables
  })
}
