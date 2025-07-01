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

variable "shutdown_minutes" {
  default     = 10
  description = "Minutes after which the EC2 instance will shut down"
}
