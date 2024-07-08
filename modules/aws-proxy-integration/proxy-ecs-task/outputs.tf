######################################################
# Outputs
######################################################


output "task_role_arn" {
  description = "The ARN of the IAM role assumed by the task"
  value       = aws_iam_role.proxy_ecs_task_role.arn
}

output "task_role_name" {
  description = "The name of the IAM role assumed by the task"
  value       = aws_iam_role.proxy_ecs_task_role.name
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.ecs_proxy_sg.id
}
