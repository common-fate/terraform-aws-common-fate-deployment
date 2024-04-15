######################################################
# Outputs
######################################################

output "ecs_deployment_failure" {
  description = "The ecs_deployment_failure SNS topic ARN"
  value       = aws_sns_topic.ecs_deployment_failures.arn
}
