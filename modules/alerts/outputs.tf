######################################################
# Outputs
######################################################

output "ecs_deployment_alerts" {
  description = "The ecs_deployment_alerts SNS topic ARN"
  value       = aws_sns_topic.ecs_deployment_alerts.arn
}
