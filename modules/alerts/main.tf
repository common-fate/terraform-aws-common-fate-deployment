
data "aws_arn" "ecs_cluster" {
  arn = var.ecs_cluster_id
}

locals {
  cluster_name = trimprefix(data.aws_arn.ecs_cluster.resource, "cluster/")
}


######################################################
# SNS topics
######################################################

// This topic is used for deployment failure alerts etc
resource "aws_sns_topic" "ecs_deployment_alerts" {
  name         = "${var.namespace}-${var.stage}-ecs-deployment-alerts"
  display_name = "Alerts for ECS service deployments"
}

######################################################
# SNS topic cloudwatch event rules
######################################################

## Start Rule Section ##
// This rule is intended to only forward deployment failure events to the topic
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
    var.alert_on_all_deployment_events == false ? {
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
## End Rule Section ##


######################################################
# Event bridge publish to SNS topic policies
######################################################

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    // add more topics to this policy
    resources = [aws_sns_topic.ecs_deployment_alerts.arn]
  }
}

// For each new topic, set the policy on the topic like this
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.ecs_deployment_alerts.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
