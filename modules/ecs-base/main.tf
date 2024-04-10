resource "aws_cloudwatch_log_group" "otel_log_group" {
  name              = "${var.namespace}-${var.stage}-otel-collector"
  retention_in_days = var.log_retention_in_days
}

resource "aws_iam_policy" "otel" {
  name        = "${var.namespace}-${var.stage}-otel-policy"
  description = "Allows AWS OpenTelemetry Collector to put traces in X-Ray"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_service_discovery_http_namespace" "internal_namespace" {
  name        = var.service_discovery_namespace_name
  description = "test"
}
