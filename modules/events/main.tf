######################################################
# Event Bus
######################################################

resource "aws_cloudwatch_event_bus" "event_bus" {
  name = "${var.namespace}-${var.stage}-event-bus"
}


resource "aws_sqs_queue" "event_queue" {
  name = "${var.namespace}-${var.stage}-event-queue"
  # Additional configurations like redrive policy can be added here
}
resource "aws_cloudwatch_event_rule" "to_sqs_rule" {
  name           = "${var.namespace}-${var.stage}-to-sqs-rule"
  description    = "Route events to SQS queue"
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
  event_pattern = jsonencode({
    "source" : ["commonfate.io/events"]
  })
}

resource "aws_cloudwatch_event_target" "sqs_target" {
  rule           = aws_cloudwatch_event_rule.to_sqs_rule.name
  target_id      = "SendToSQS"
  arn            = aws_sqs_queue.event_queue.arn
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
}

resource "aws_sqs_queue_policy" "event_queue_policy" {
  queue_url = aws_sqs_queue.event_queue.url

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.event_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : aws_cloudwatch_event_rule.to_sqs_rule.arn
          }
        }
      }
    ]
  })
}
# resource "aws_cloudwatch_log_group" "event_log_group" {
#   name = "${var.namespace}-${var.stage}-event-log-group"
#   # Additional configurations like retention can be added here
# }

# resource "aws_cloudwatch_event_rule" "to_cw_logs_rule" {
#   name           = "${var.namespace}-${var.stage}-to-cw-logs-rule"
#   description    = "Route events to CloudWatch Log Group"
#   event_bus_name = aws_cloudwatch_event_bus.event_bus.name
#   event_pattern  = jsonencode({
#     "source": ["commonfate.io/events"]
#   })
# }

# resource "aws_cloudwatch_event_target" "cw_logs_target" {
#   rule      = aws_cloudwatch_event_rule.to_cw_logs_rule.name
#   target_id = "SendToCloudWatchLogs"
#   arn       = aws_cloudwatch_log_group.event_log_group.arn
# }

