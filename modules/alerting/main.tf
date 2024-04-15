######################################################
# SNS topics
######################################################

// This topic is used for deployment failure alerts etc
resource "aws_sns_topic" "ecs_deployment_alerts" {
  name = "${var.namespace}-${var.stage}-ecs-deployment-alerts"
}


######################################################
# SNS topic subscriptions
######################################################

// This allows one or more webhooks to be subscribed to the ecs deployments alerts topic
resource "aws_sns_topic_subscription" "ecs_deployment_alerts_webhook_subscription" {
  for_each  = var.ecs_deployment_alerts_webhooks_subscription_urls
  topic_arn = aws_sns_topic.ecs_deployment_alerts.arn
  protocol  = "https"
  endpoint  = each.value
}

######################################################
# SNS topic cloudwatch event rules
######################################################

## Start Rule Section ##
// This rule is intended to only forward deployment failure events to the topic
resource "aws_cloudwatch_event_rule" "ecs_service_deployment_failure" {
  name        = "${var.namespace}-${var.stage}-ecs-service-deployment-failure"
  description = "Captures ecs service deployment failures"

  event_pattern = jsonencode({
    "source" : ["aws.ecs"],
    "detail-type" : ["ECS Deployment State Change"],
    "detail" : {
      "clusterArn" : [var.ecs_cluster_arn],
      # "eventName" : ["SERVICE_DEPLOYMENT_FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ecs_service_deployment_failure_to_sns" {
  rule      = aws_cloudwatch_event_rule.ecs_service_deployment_failure.name
  target_id = "${var.namespace}-${var.stage}-ecs-service-deployment-failure-to-sns"
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

