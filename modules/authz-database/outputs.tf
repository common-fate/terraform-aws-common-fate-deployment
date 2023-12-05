######################################################
# Outputs
######################################################

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.global_table.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table."
  value       = aws_dynamodb_table.global_table.arn
}

output "dynamodb_table_id" {
  description = "The unique identifier of the DynamoDB table."
  value       = aws_dynamodb_table.global_table.id
}
