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
resource "aws_cloudwatch_log_group" "event_log_group" {
  name_prefix       = "/aws/events/${var.namespace}-${var.stage}/events"
  retention_in_days = var.log_retention_in_days

}
# Create a Log Policy to allow Cloudwatch to Create log streams and put logs
resource "aws_cloudwatch_log_resource_policy" "events_policy" {
  policy_name     = "${var.namespace}-${var.stage}-event-logs-policy"
  policy_document = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "CWLogsPolicy",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [ 
          "events.amazonaws.com",
          "delivery.logs.amazonaws.com"
          ]
      },
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
        ],
      "Resource": "${aws_cloudwatch_log_group.event_log_group.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.to_cw_logs_rule.arn}"
        }
      }
    }
  ]
}
POLICY  
}

#Create a new Event Rule
resource "aws_cloudwatch_event_rule" "to_cw_logs_rule" {
  name           = "${var.namespace}-${var.stage}-to-cloudwatch-rule"
  description    = "Route events to cloudwatch"
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
  event_pattern = jsonencode({
    "source" : ["commonfate.io/events"]
  })
}


resource "aws_cloudwatch_event_target" "cw_logs_target" {
  rule           = aws_cloudwatch_event_rule.to_cw_logs_rule.name
  arn            = aws_cloudwatch_log_group.event_log_group.arn
  event_bus_name = aws_cloudwatch_event_bus.event_bus.name
  target_id      = "SendToCloudwatch"
}

