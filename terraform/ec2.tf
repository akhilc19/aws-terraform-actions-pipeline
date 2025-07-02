# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg-${var.stage}"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "WebSG-${var.stage}"
    Stage = var.stage
  }
}

# EC2 Instance
resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile_b.name


  user_data = templatefile("${path.module}/../scripts/${lower(var.stage)}_script.sh", {
    s3_bucket_name   = var.s3_bucket_name
    aws_region       = var.aws_region
    repo_url         = var.repo_url
    shutdown_minutes = var.shutdown_minutes
  })

  tags = {
    Name  = "TecheazyApp-${var.stage}"
    Stage = var.stage
  }
}
