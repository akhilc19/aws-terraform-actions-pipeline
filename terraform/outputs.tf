output "instance_public_ip" {
  value = aws_instance.app.public_ip
}
output "s3_log_bucket" {
  description = "Name of the S3 bucket where logs are stored"
  value       = aws_s3_bucket.log_s3_bucket.id
}

output "iam_role_a_arn" {
  description = "ARN of IAM Role A (read access to S3)"
  value       = aws_iam_role.role_a_readonly.arn
}

output "iam_role_b_arn" {
  description = "ARN of IAM Role B (attached to EC2 instance)"
  value       = aws_iam_role.role_b_uploader.arn
}

