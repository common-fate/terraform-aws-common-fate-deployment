
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

resource "aws_cloudwatch_event_rule" "ecs_service_deployment_alerts" {
  name        = "${var.namespace}-${var.stage}-ecs-service-deployment-alerts"
  description = "Alerts for ECS service deployments"

  event_pattern = jsonencode(merge({
    "source" : ["aws.ecs"],
    "detail-type" : ["ECS Deployment State Change"],
    "resources" : [
      {
        "prefix" : "arn:aws:ecs:${var.aws_region}:${var.aws_account_id}:service/${local.cluster_name}"
      }
    ]
    },
    // only alert on SERVICE_DEPLOYMENT_FAILED events if alert_on_all_deployment_events is false
    var.alerts["all_deployment_events"] == false ? {
      "detail" : {
        "eventName" : "SERVICE_DEPLOYMENT_FAILED"
      }
    } : {}
  ))
}

resource "aws_cloudwatch_event_target" "ecs_service_deployment_alerts_to_sns" {
  rule      = aws_cloudwatch_event_rule.ecs_service_deployment_alerts.name
  target_id = "${var.namespace}-${var.stage}-ecs-service-deployment-alerts-to-sns"
  arn       = aws_sns_topic.ecs_deployment_alerts.arn
}

resource "aws_sns_topic" "ecs_deployment_alerts" {
  name         = "${var.namespace}-${var.stage}-ecs-deployment-alerts"
  display_name = "Alerts for ECS service deployments"
}

data "aws_iam_policy_document" "ecs_deployment_alerts" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.ecs_deployment_alerts.arn]
  }
}

resource "aws_sns_topic_policy" "ecs_deployment_alerts" {
  arn    = aws_sns_topic.ecs_deployment_alerts.arn
  policy = data.aws_iam_policy_document.ecs_deployment_alerts.json
}

######################################################
# Background job alerts
#
# Emitted when Common Fate background jobs complete or fail.
# By default we only emit events on failed jobs.
######################################################

resource "aws_cloudwatch_event_rule" "job_alerts" {
  name        = "${var.namespace}-${var.stage}-job-alerts"
  description = "Alerts for Common Fate background jobs"

  event_pattern = jsonencode({
    "source" : ["commonfate.io/events"],
    "detail-type" : var.alerts["all_job_events"] ? ["job.completed", "job.failed"] : ["job.failed"],
    },
  )
}

resource "aws_cloudwatch_event_target" "job_alerts_to_sns" {
  rule      = aws_cloudwatch_event_rule.ecs_service_deployment_alerts.name
  target_id = "${var.namespace}-${var.stage}-job-alerts-to-sns"
  arn       = aws_sns_topic.ecs_deployment_alerts.arn
}

resource "aws_sns_topic" "job_alerts" {
  name         = "${var.namespace}-${var.stage}-job-alerts"
  display_name = "Alerts for Common Fate background jobs"
}

data "aws_iam_policy_document" "job_alerts" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.job_alerts.arn]
  }
}

resource "aws_sns_topic_policy" "job_alerts" {
  arn    = aws_sns_topic.job_alerts.arn
  policy = data.aws_iam_policy_document.job_alerts.json
}
