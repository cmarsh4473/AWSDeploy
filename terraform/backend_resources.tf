/*
  Backend resources that can be created by Terraform to host remote state.
  NOTE: You must run `terraform apply` locally (or from a runner) with these variables set
  to create the bucket/table, then re-run `terraform init` with backend-config to migrate state.
*/

resource "aws_s3_bucket" "tfstate" {
  count = var.backend_s3_bucket != "" ? 1 : 0

  bucket = var.backend_s3_bucket
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "${var.name}-tfstate"
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  count = var.backend_dynamodb_table != "" ? 1 : 0

  name         = var.backend_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"

  tags = {
    Name = "${var.name}-tf-locks"
  }
}

output "backend_s3_bucket" {
  value       = aws_s3_bucket.tfstate.*.bucket
  description = "S3 bucket created for remote state (if any)"
}

output "backend_dynamodb_table" {
  value       = aws_dynamodb_table.tf_locks.*.name
  description = "DynamoDB table created for state locking (if any)"
}
