output "this_eks_cluster_id" {
  description = "The ID/Name of the EKS Cluster"
  value       = data.aws_eks_cluster.main.id
}
output "this_loadbalancer_logging_s3_bucket_name" {
  description = "The ID/Name of the S3 Bucket for Load Balancer Logging."
  value       = module.loadbalancer_logging_s3_bucket.this_bucket_id
}
