######################################################
# Outputs
######################################################

output "ecs_deployment_alerts_topic_arn" {
  description = "The ecs_deployment_alerts sns topic ARN"
  value       = aws_sns_topic.ecs_deployment_alerts.arn
}
