variable "region" {
  description = "AWS Region, e.g. eu-central-1"
  type        = string
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubeconfig_auth_api_version" {
  type        = string
  default     = "client.authentication.k8s.io/v1beta1"
  description = "API version for authentication in kubeconfig"
}
variable "kubeconfig_auth_command" {
  description = "Command to use to fetch AWS EKS credentials."
  type        = string
  default     = "aws"
}

variable "kubeconfig_auth_command_args" {
  description = "Default arguments passed on authenticating. Defaults to [--region $region eks get-token --cluster-name $cluster_name]."
  type        = list(string)
  default     = []
}

variable "kubeconfig_auth_additional_args" {
  description = "Any additional arguments to pass on authenticating such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = list(string)
  default     = []
}

variable "kubeconfig_auth_env_variables" {
  description = "Environment variables that should be used on authenticating. e.g. { AWS_PROFILE = \"eks\"}."
  type        = map(string)
  default     = {}
}

variable "kubeconfig_output_path" {
  description = "Where to save the Kubectl config file. Assumed to be a directory if the value ends with a forward slash `/`."
  type        = string
  default     = "./"
}
variable "kubeconfig_file_permission" {
  description = "File permission of the Kubectl config file containing cluster configuration saved to `kubeconfig_output_path.`"
  type        = string
  default     = "0600"
}
