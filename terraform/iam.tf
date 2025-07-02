# Role A: Read-Only Access to S3

resource "aws_iam_role" "role_a_readonly" {
  name = "readonly_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "readonly_policy" {
  name        = "readonly_s3_policy"
  description = "Allows read-only access to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:ListBucket", "s3:GetObject"],
        Effect   = "Allow",
        Resource = ["arn:aws:s3:::${var.s3_bucket_name}", "arn:aws:s3:::${var.s3_bucket_name}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "readonly_attach" {
  role       = aws_iam_role.role_a_readonly.name
  policy_arn = aws_iam_policy.readonly_policy.arn
}

# Role B: Write-Only Access to S3
resource "aws_iam_role" "role_b_uploader" {
  name = "uploadonly_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "uploadonly_policy" {
  name        = "uploadonly_s3_policy"
  description = "Allows write-only access to S3 and the ability to assume Role A"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:CreateBucket"],
        Resource = ["arn:aws:s3:::${var.s3_bucket_name}", "arn:aws:s3:::${var.s3_bucket_name}/*"]
      },
      {
        Effect   = "Deny",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = ["arn:aws:s3:::*"]
      },
      {
        Effect   = "Allow",
        Action   = ["sts:AssumeRole"],
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/readonly_s3_role"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "uploadonly_attach" {
  role       = aws_iam_role.role_b_uploader.name
  policy_arn = aws_iam_policy.uploadonly_policy.arn
}

# Instance profiles for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile_a" {
  name = "${var.stage}_readonly_instance_profile"
  role = aws_iam_role.role_a_readonly.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile_b" {
  name = "${var.stage}_writeonly_instance_profile"
  role = aws_iam_role.role_b_uploader.name
}
