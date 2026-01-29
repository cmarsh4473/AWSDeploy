resource "aws_ecr_repository" "lambda_repo" {
  name = var.lambda_repo_name
}
