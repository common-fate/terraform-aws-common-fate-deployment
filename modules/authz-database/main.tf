resource "aws_dynamodb_table" "global_table" {
  name         = "${var.namespace}-${var.stage}-dynamodb-table"
  billing_mode = "PAY_PER_REQUEST"
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  hash_key  = "PK"
  range_key = "SK"

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  tags = {
    Name      = "${var.namespace}-${var.stage}-dynamodb-table"
    Namespace = var.namespace
    Stage     = var.stage
  }
  restore_date_time      = var.dynamodb_restore_date_time
  restore_source_name    = var.dynamodb_restore_source_name
  restore_to_latest_time = var.dynamodb_restore_to_latest_time
}
