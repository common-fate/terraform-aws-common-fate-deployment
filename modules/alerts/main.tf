
data "aws_arn" "ecs_cluster" {
  arn = var.ecs_cluster_id
}

locals {
  cluster_name = trimprefix(data.aws_arn.ecs_cluster.resource, "cluster/")
}


######################################################
# Deployment alerts
#
# Emitted when ECS deployment events occur.
# By default we only emit events on deployment failures.
######################################################

resource "aws_cloudwatch_event_rule" "deployment_failures" {
  name        = "${var.namespace}-${var.stage}-deployment-failures"
  description = "Common Fate service deployment failures"

  event_pattern = jsonencode(
    {
      "source" : ["aws.ecs"],
      "detail-type" : ["ECS Deployment State Change"],
      "resources" : [
        {
          "prefix" : "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:service/${local.cluster_name}"
        }
      ]
      "detail" : {
        "eventName" : ["SERVICE_DEPLOYMENT_FAILED"]
      }
    },
  )
}

resource "aws_cloudwatch_event_target" "deployment_failures" {
  rule      = aws_cloudwatch_event_rule.deployment_failures.name
  target_id = "${var.namespace}-${var.stage}-deployment-failures-to-sns"
  arn       = aws_sns_topic.deployment_failures.arn

  input_transformer {
    input_paths = {
      reason        = "$.detail.reason"
      deployment_id = "$.detail.deploymentId"
    }
    input_template = <<EOF
    {
      "title": "ECS service deployment has failed",
      "description": "<reason>",
      "metadata": ${jsonencode(var.alert_metadata)},
      "event": <aws.events.event.json>
    }
    EOF
  }
}

resource "aws_sns_topic" "deployment_failures" {
  name         = "${var.namespace}-${var.stage}-deployment-alerts"
  display_name = "Common Fate deployment alerts"
}

data "aws_iam_policy_document" "deployment_failures" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.deployment_failures.arn]
  }
}

resource "aws_sns_topic_policy" "deployment_failures" {
  arn    = aws_sns_topic.deployment_failures.arn
  policy = data.aws_iam_policy_document.deployment_failures.json
}

######################################################
# Background job alerts
#
# Emitted when Common Fate background jobs complete or fail.
# By default we only emit events on failed jobs.
######################################################

resource "aws_cloudwatch_event_rule" "job_failures" {
  name           = "${var.namespace}-${var.stage}-job-failures"
  description    = "Alerts for Common Fate background job failures"
  event_bus_name = var.event_bus_name

  event_pattern = jsonencode({
    "source" : ["commonfate.io/events"],
    "detail-type" : ["job.failed"],
    },
  )
}

resource "aws_cloudwatch_event_target" "job_failures" {
  rule           = aws_cloudwatch_event_rule.job_failures.name
  target_id      = "${var.namespace}-${var.stage}-job-failures"
  arn            = aws_sns_topic.job_failures.arn
  event_bus_name = var.event_bus_name

  input_transformer {
    input_paths = {
      job_kind = "$.detail.job_kind"
      job_id   = "$.detail.job_id"
      error    = "$.detail.error"
    }
    input_template = <<EOF
    {
      "title": "Job <job_kind> has failed",
      "description": "Job <job_id> failed with error: `<error>`.",
      "metadata": ${jsonencode(var.alert_metadata)},
      "event": <aws.events.event.json>
    }
    EOF
  }
}

resource "aws_sns_topic" "job_failures" {
  name         = "${var.namespace}-${var.stage}-job-alerts"
  display_name = "Alerts for Common Fate background jobs"
}

data "aws_iam_policy_document" "job_failures" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.job_failures.arn]
  }
}

resource "aws_sns_topic_policy" "job_failures" {
  arn    = aws_sns_topic.job_failures.arn
  policy = data.aws_iam_policy_document.job_failures.json
}
