#
# Creates the S3 bucket for (all) LoadBalancers access logging
#
resource "aws_s3_bucket" "main" {
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  bucket        = var.name
  force_destroy = true
}
resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  # Important: No parallel changes, otherwise:
  # aws_s3_bucket_public_access_block.sample: error creating public access block policy for S3 bucket (BUCKETNAME): OperationAborted: A conflicting conditional operation is currently in progress against this resource. Please try again.
  depends_on = [aws_s3_bucket_acl.main]

  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  # Important: No parallel changes, otherwise:
  # aws_s3_bucket_public_access_block.sample: error creating public access block policy for S3 bucket (BUCKETNAME): OperationAborted: A conflicting conditional operation is currently in progress against this resource. Please try again.
  depends_on = [aws_s3_bucket_server_side_encryption_configuration.main]

  bucket = aws_s3_bucket.main.id
  rule {
    id = "delete-after-30-days"
    expiration {
      days = 30
    }
    status = "Enabled"
  }
  rule {
    id = "delete-incomplete-multipart-uploads-after-1-day"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
  }
}

#
# https-only - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
#
resource "aws_s3_bucket_policy" "main" {
  # Important: No parallel changes, otherwise:
  # aws_s3_bucket_public_access_block.sample: error creating public access block policy for S3 bucket (BUCKETNAME): OperationAborted: A conflicting conditional operation is currently in progress against this resource. Please try again.
  depends_on = [aws_s3_bucket_lifecycle_configuration.main]

  bucket = aws_s3_bucket.main.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::${local.aws_loadbalancer_account_id_by_region[var.region]}:root" },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.main.arn}/*"
    },
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {"Service": "delivery.logs.amazonaws.com"},
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.main.arn}/*",
      "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
    },
    {
      "Sid": "AWSLogDeliveryAclCheck",
      "Effect": "Allow",
      "Principal": {"Service": "delivery.logs.amazonaws.com"},
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.main.arn}"
    },
    {
      "Sid": "HttpsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.main.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "main" {
  # Important: No parallel changes, otherwise:
  # aws_s3_bucket_public_access_block.sample: error creating public access block policy for S3 bucket (BUCKETNAME): OperationAborted: A conflicting conditional operation is currently in progress against this resource. Please try again.
  depends_on = [aws_s3_bucket_policy.main]

  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
