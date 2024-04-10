output "otel_log_group_name" {
  value = aws_cloudwatch_log_group.otel_log_group.name
}

output "otel_writer_iam_policy_arn" {
  value = aws_iam_policy.otel.arn
}

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_http_namespace.internal_namespace.arn
}

