variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name (optional)"
  type        = string
  default     = ""
}

variable "lambda_repo_name" {
  description = "ECR repository name for the lambda image"
  type        = string
  default     = "lambda-repo"
}
