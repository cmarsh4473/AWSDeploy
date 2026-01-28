variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type (free tier eligible: t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "(Optional) Path to your SSH public key file. If set, Terraform will create an AWS key pair from it." 
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "CIDR allowed to connect via SSH (consider restricting this in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "name" {
  description = "Name prefix for resources"
  type        = string
  default     = "terraform-ec2-free-tier"
}
