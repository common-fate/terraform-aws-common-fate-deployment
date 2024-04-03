######################################################
# RDS Postgres Database
######################################################



resource "aws_security_group" "rds_sg" {

  name        = "${var.namespace}-${var.stage}-rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id
}

resource "aws_db_parameter_group" "postgres_db" {
  name   = "${var.namespace}-${var.stage}-postgres-db"
  family = "postgres15"
}

#trivy:ignore:AVD-AWS-0080
resource "aws_db_instance" "pg_db" {
  identifier                   = "${var.namespace}-${var.stage}-pg-db"
  allocated_storage            = 20
  engine                       = "postgres"
  engine_version               = "15"
  instance_class               = "db.t3.micro"
  db_name                      = "postgres"
  username                     = "postgres"
  manage_master_user_password  = true
  parameter_group_name         = aws_db_parameter_group.postgres_db.name
  skip_final_snapshot          = true
  db_subnet_group_name         = var.subnet_group_id
  vpc_security_group_ids       = [aws_security_group.rds_sg.id]
  deletion_protection          = var.deletion_protection
  performance_insights_enabled = true
  storage_encrypted            = true
  backup_retention_period      = var.db_retention_period


  restore_to_point_in_time {
    restore_time                  = var.apply_pitr_backup_rds ? var.pitr_restore_time : null
    source_db_instance_identifier = var.apply_pitr_backup_rds ? aws_db_parameter_group.postgres_db.id : null
  }

  lifecycle {
    ignore_changes = [storage_encrypted, restore_to_point_in_time]
  }
}
