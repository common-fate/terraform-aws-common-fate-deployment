######################################################
# Outputs
######################################################

output "security_group_id" {
  description = "The security group ID associated with the RDS instance."
  value       = aws_security_group.rds_sg.id
}

output "username" {
  description = "The username for accessing the RDS database instance."
  value       = aws_db_instance.pg_db.username
}

output "endpoint" {
  description = "The endpoint address of the RDS database instance."
  value       = aws_db_instance.pg_db.endpoint
}

output "secret_arn" {
  description = "The Amazon Resource Name (ARN) of the secret associated with the RDS database instance."
  value       = aws_db_instance.pg_db.master_user_secret.0.secret_arn
}
