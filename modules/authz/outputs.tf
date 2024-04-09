######################################################
# Outputs
######################################################


output "service_discovery_namespace_arn" {
  value = aws_service_discovery_http_namespace.test.arn
}
