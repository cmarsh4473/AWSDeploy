output "api_endpoint" {
  description = "HTTP API endpoint URL"
  value       = aws_apigatewayv2_api.http.api_endpoint
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.app.function_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "log_group" {
  description = "CloudWatch Log Group for the Lambda"
  value       = aws_cloudwatch_log_group.lambda.name
}
