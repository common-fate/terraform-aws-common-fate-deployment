######################################################
# RDS Postgres Database
######################################################



resource "aws_security_group" "rds_sg" {
  name        = "${var.namespace}-${var.stage}-rds-security-group-mysql"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id
}


#trivy:ignore:AVD-AWS-0080
resource "aws_db_instance" "mysql_db" {
  identifier        = "${var.namespace}-${var.stage}-mysql-db"
  allocated_storage = 20

  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "mysql"
  username               = "mysql"
  password               = "password"
  skip_final_snapshot    = true
  db_subnet_group_name   = var.subnet_group_id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  apply_immediately      = true

  lifecycle {
    ignore_changes = [storage_encrypted]
  }
}
