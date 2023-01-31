output "this_bucket_id" {
  value       = aws_s3_bucket.main.id
  description = "The name of the bucket."
}
output "this_bucket_arn" {
  value       = aws_s3_bucket.main.arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
}
