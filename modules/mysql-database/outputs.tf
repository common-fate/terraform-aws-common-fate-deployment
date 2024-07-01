######################################################
# Outputs
######################################################

output "security_group_id" {
  description = "The security group ID associated with the RDS instance."
  value       = aws_security_group.rds_sg.id
}

output "username" {
  description = "The username for accessing the RDS database instance."
  value       = aws_db_instance.mysql_db.username
}

output "endpoint" {
  description = "The endpoint address of the RDS database instance."
  value       = aws_db_instance.mysql_db.endpoint
}

output "outputs" {
  description = "outputs"
  value       = aws_db_instance
}
