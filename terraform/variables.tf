variable "aws_region" {
  default     = "ap-south-1"
  description = "AWS Mumbai region"
}
variable "ami_id" {
  # default     = "ami-0f918f7e67a3323f0"
  #description = "AMI ID for Ubuntu 24"
  default     = "ami-00cb641b494eae1e8" #my own ec2 ami with pre installed tools
  description = "Using own custom ec2 ami with pre installed aws cli v2, java 21, git, maven, curl"
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
  default     = "techeazy-logs-dev-unique123ss"
  validation {
    condition     = length(var.s3_bucket_name) > 0
    error_message = "S3 bucket name cannot be empty."
  }
}
variable "shutdown_minutes" {
  description = "Shutdown timer for main instance"
  type        = number
  default     = 25
}
variable "verifier_lifetime" {
  description = "Shutdown timer for verifier instance"
  type        = number
  default     = 25
}
