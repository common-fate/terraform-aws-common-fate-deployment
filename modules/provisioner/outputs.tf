######################################################
# Outputs
######################################################

output "provisioner_url" {
  value = "http://${aws_service_discovery_service.service.name}.${aws_service_discovery_private_dns_namespace.service_discovery.name}:9999"
}

output "task_role_arn" {
  description = "The ARN of the IAM role assumed by the task"
  value       = aws_iam_role.provisioner_ecs_task_role.arn
}

