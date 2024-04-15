
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

resource "aws_cloudwatch_event_rule" "deployments" {
  name        = "${var.namespace}-${var.stage}-deployment-alerts"
  description = "Common Fate service deployment alerts"

  event_pattern = jsonencode(merge({
    "source" : ["aws.ecs"],
    "detail-type" : ["ECS Deployment State Change"],
    "resources" : [
      {
        "prefix" : "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:service/${local.cluster_name}"
      }
    ]
    },
    // only alert on SERVICE_DEPLOYMENT_FAILED events if deployments is set to error level
    var.alerts["deployments"] == "errors" ? {
      "detail" : {
        "eventName" : "SERVICE_DEPLOYMENT_FAILED"
      }
    } : {}
  ))
}

resource "aws_cloudwatch_event_target" "deployments" {
  rule      = aws_cloudwatch_event_rule.deployments.name
  target_id = "${var.namespace}-${var.stage}-deployment-alerts-to-sns"
  arn       = aws_sns_topic.deployments.arn
}

resource "aws_sns_topic" "deployments" {
  name         = "${var.namespace}-${var.stage}-deployment-alerts"
  display_name = "Common Fate deployment alerts"
}

data "aws_iam_policy_document" "deployments" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.deployments.arn]
  }
}

resource "aws_sns_topic_policy" "deployments" {
  arn    = aws_sns_topic.deployments.arn
  policy = data.aws_iam_policy_document.deployments.json
}

######################################################
# Background job alerts
#
# Emitted when Common Fate background jobs complete or fail.
# By default we only emit events on failed jobs.
######################################################

resource "aws_cloudwatch_event_rule" "jobs" {
  name        = "${var.namespace}-${var.stage}-job-alerts"
  description = "Alerts for Common Fate background jobs"

  event_pattern = jsonencode({
    "source" : ["commonfate.io/events"],
    "detail-type" : var.alerts["jobs"] == "all" ? ["job.completed", "job.failed"] : ["job.failed"],
    },
  )
}

resource "aws_cloudwatch_event_target" "jobs" {
  rule      = aws_cloudwatch_event_rule.jobs.name
  target_id = "${var.namespace}-${var.stage}-job-alerts-to-sns"
  arn       = aws_sns_topic.jobs.arn
}

resource "aws_sns_topic" "jobs" {
  name         = "${var.namespace}-${var.stage}-job-alerts"
  display_name = "Alerts for Common Fate background jobs"
}

data "aws_iam_policy_document" "jobs" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.jobs.arn]
  }
}

resource "aws_sns_topic_policy" "jobs" {
  arn    = aws_sns_topic.jobs.arn
  policy = data.aws_iam_policy_document.jobs.json
}
