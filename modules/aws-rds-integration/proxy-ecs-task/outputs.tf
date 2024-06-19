######################################################
# Outputs
######################################################


output "task_role_arn" {
  description = "The ARN of the IAM role assumed by the task"
  value       = aws_iam_role.provisioner_ecs_task_role.arn
}

output "task_role_name" {
  description = "The name of the IAM role assumed by the task"
  value       = aws_iam_role.provisioner_ecs_task_role.name
}

