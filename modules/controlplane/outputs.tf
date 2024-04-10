######################################################
# Outputs
######################################################

output "task_role_arn" {
  description = "The ARN of the IAM role assumed by the task"
  value       = aws_iam_role.control_plane_ecs_task_role.arn
}


output "security_group_id" {
  value = aws_security_group.ecs_control_plane_sg_v2.id
}

output "worker_security_group_id" {
  value = aws_security_group.ecs_worker_sg.id
}
