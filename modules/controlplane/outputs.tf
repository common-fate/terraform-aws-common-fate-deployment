######################################################
# Outputs
######################################################

output "task_role_arn" {
  description = "The ARN of the IAM role assumed by the task"
  value       = aws_iam_role.control_plane_ecs_task_role.arn
}

