# Private S3 Bucket for storing logs
resource "aws_s3_bucket" "log_s3_bucket" {
  bucket = var.s3_bucket_name
  tags = {
    Name = "LogBucket-${var.stage}"
  }
  force_destroy = true #Use at Caution
}

# Enforce private access controls
resource "aws_s3_bucket_public_access_block" "log_bucket_access_block" {
  bucket = aws_s3_bucket.log_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule to delete logs after 7 days
resource "aws_s3_bucket_lifecycle_configuration" "log_lifecycle" {
  bucket = aws_s3_bucket.log_s3_bucket.id
  rule {
    id     = "delete_old_logs"
    status = "Enabled"

    expiration {
      days = 7
    }
    filter {
      prefix = ""
    }
  }
}
