variable "aws_region" {
  default     = "ap-south-1"
  description = "AWS Mumbai region"
}
variable "ami_id" {
  # default     = "ami-0d03cb826412c6b0f"
  # description = "AMI ID for Amazon Linux 2023"
  default     = "ami-0f918f7e67a3323f0"
  description = "AMI ID for Ubuntu 24"
}
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
variable "key_name" {
  description = "Name of existing EC2 Key Pair"
}

variable "stage" {
  description = "Environment stage - Dev or Prod"
}
variable "repo_url" {
  default     = "https://github.com/techeazy-consulting/techeazy-devops"
  description = "GitHub repo to deploy"
}
variable "s3_bucket_name" {
  description = "S3 bucket name for logs (must be globally unique)"
  type        = string
  default     = "techeazy-logs-bucket-39u2390423"
  validation {
    condition     = length(var.s3_bucket_name) > 0
    error_message = "S3 bucket name cannot be empty."
  }
}
variable "shutdown_minutes" {
  description = "Auto-shutdown timer in minutes"
  type        = number
  default     = 10
}
