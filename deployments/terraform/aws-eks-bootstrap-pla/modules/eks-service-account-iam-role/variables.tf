variable "account_id" {
  type        = string
  description = "ID of the AWS account"
}
variable "oidc_provider_url" {
  type        = string
  description = "URL of the AWS OIDC Provider associated with the EKS cluster"
}
variable "name" {
  type        = string
  description = "Name of the IAM role."
}
variable "service_accounts" {
  type        = list(string)
  description = "List of Kubernetes service accounts (in the format namespace/serviceaccount) that are trusted to assume this role. Can also be namespace/*"
}
variable "inline_policies" {
  type        = list(string)
  description = "A list of policies in JSON format which will be attached to the IAM role as inline-policies."
  default     = []
}
variable "extra_assume_role_policy_statements" {
  description = "A list of additional IAM policies statements which will be added and combined/merged to a single assume role policy."
  type        = list(any)
  default     = []
}
variable "policy_arns" {
  type        = list(string)
  description = "A list of existing IAM policy ARNs which will be attached to the IAM role."
  default     = []
}