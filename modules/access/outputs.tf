######################################################
# Outputs
######################################################

output "security_group_id" {
  value = aws_security_group.ecs_access_handler_sg_v2.id
}
