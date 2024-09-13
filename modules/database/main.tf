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
  identifier                   = "${var.namespace}-${var.stage}-pg-db${var.suffix}"
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
  backup_retention_period      = var.rds_db_retention_period
  multi_az                     = var.rds_multi_az
  apply_immediately            = var.apply_immediately
  snapshot_identifier          = var.snapshot_identifier


  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [1] : []
    content {
      restore_time                             = var.restore_to_point_in_time.restore_time
      source_db_instance_identifier            = var.restore_to_point_in_time.source_db_instance_identifier
      source_dbi_resource_id                   = var.restore_to_point_in_time.source_dbi_resource_id
      use_latest_restorable_time               = var.restore_to_point_in_time.use_latest_restorable_time
      source_db_instance_automated_backups_arn = var.restore_to_point_in_time.source_db_instance_automated_backups_arn
    }
  }



  lifecycle {
    ignore_changes = [storage_encrypted]
  }
}
