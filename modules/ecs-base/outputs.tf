output "otel_log_group_name" {
  value = aws_cloudwatch_log_group.otel_log_group.name
}

output "otel_writer_iam_policy_arn" {
  value = aws_iam_policy.otel.arn
}
