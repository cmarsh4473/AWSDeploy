variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}
variable "name" {
  description = "Name prefix for resources"
  type        = string
  default     = "terraform-ec2-freetier"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention (days) for the Lambda"
  type        = number
  default     = 1
}

