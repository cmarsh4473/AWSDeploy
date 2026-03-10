terraform {
  backend "s3" {
    # S3 bucket and DynamoDB table are configured via -backend-config flags
    # in the Terraform init command (see GitHub Actions workflow)
    encrypt        = true
    dynamodb_table = ""  # Set via -backend-config
    bucket         = ""  # Set via -backend-config
    key            = "wordpress/terraform.tfstate"
  }
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}
