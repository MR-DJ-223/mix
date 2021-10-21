output "arn" {
  description = "ARN for the lambda function"
  value       = aws_lambda_function.this.arn
}

output "qualified_arn" {
  description = "Qualified ARN for the lambda function"
  value       = aws_lambda_function.this.qualified_arn
}

output "function_name" {
  description = "ARN for the lambda function"
  value       = aws_lambda_function.this.function_name
}