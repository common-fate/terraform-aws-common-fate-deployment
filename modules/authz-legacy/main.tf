


resource "aws_cloudwatch_log_group" "authz_log_group" {
  name              = "${var.namespace}-${var.stage}-authz"
  retention_in_days = var.log_retention_in_days
}
