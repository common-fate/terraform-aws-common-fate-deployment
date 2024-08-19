
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

dynamic "input_transformer" {
    for_each = var.use_opsgenie_format ? [] : [1]

    content {
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

  dynamic "input_transformer" {
    for_each = var.use_opsgenie_format ? [] : [1]

    content {
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

######################################################
# Load Balancer Alerts
#
# Emitted when Common Fate load balancer is unhealthy
# By default, we only emit events on failed jobs.
######################################################

resource "aws_sns_topic" "load_balancer_alerts" {
  name         = "${var.namespace}-${var.stage}-load-balancer-alerts"
  display_name = "Common Fate deployment load balancer alerts"
}

resource "aws_cloudwatch_metric_alarm" "elb_unhealthy_hostcount_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-alb-unhealthy-hostcount-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60 # 1 minute
  statistic           = "Sum"
  alarm_description   = "Alarm when UnHealthyHostCount exceeds 1 for 2 consecutive periods"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup = var.control_plane_tg_arn_suffix
  }

  alarm_actions = [aws_sns_topic.load_balancer_alerts.arn]
  ok_actions = [aws_sns_topic.load_balancer_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-alb-target-response-time-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60  # 1 minute
  statistic           = "Average"
  threshold           = 60
  alarm_description   = "Alarm when TargetResponseTime exceeds 60 seconds for 2 consecutive periods"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.load_balancer_alerts.arn]
  ok_actions = [aws_sns_topic.load_balancer_alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "alb_5xx_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-alb-5xx-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60 # 1 minute
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alarm when the number of 5xx errors on the ALB exceeds 10 for 2 consecutive periods"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.load_balancer_alerts.arn]
  ok_actions = [aws_sns_topic.load_balancer_alerts.arn]
}


######################################################
# Database Alerts
#
# Emitted when Common Fate database is unhealthy
# By default, we only emit events on failed jobs.
######################################################

resource "aws_sns_topic" "database_alerts" {
  name         = "${var.namespace}-${var.stage}-database-alerts"
  display_name = "Common Fate deployment database alerts"
}

resource "aws_cloudwatch_metric_alarm" "sql_database_cpu_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-rds-cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU utilization exceeds 80% for 2 consecutive periods"

  dimensions = {
    DBInstanceIdentifier = "${var.namespace}-${var.stage}-pg-db"
  }

  alarm_actions = [aws_sns_topic.database_alerts.arn]
  ok_actions = [aws_sns_topic.database_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-pg-db-freeable-memory-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 10000000
  alarm_description   = "Alarm when Freeable Memory is less than 10MB for 2 consecutive periods"

  dimensions = {
    DBInstanceIdentifier = "${var.namespace}-${var.stage}-pg-db"
  }

  alarm_actions = [aws_sns_topic.database_alerts.arn]
  ok_actions = [aws_sns_topic.database_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "read_iops_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-pg-db-read-iops-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Alarm when Read IOPS exceeds 100 for 2 consecutive periods"

  dimensions = {
    DBInstanceIdentifier = "${var.namespace}-${var.stage}-pg-db"
  }

  alarm_actions = [aws_sns_topic.database_alerts.arn]
  ok_actions = [aws_sns_topic.database_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-pg-db-free-storage-space-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 1 # Adjust threshold based on your requirement (in GB)
  alarm_description   = "Alarm when Free Storage Space is less than 1GB for 2 consecutive periods"

  dimensions = {
    DBInstanceIdentifier = "${var.namespace}-${var.stage}-pg-db"
  }

  alarm_actions = [aws_sns_topic.database_alerts.arn]
  ok_actions = [aws_sns_topic.database_alerts.arn]
}

######################################################
# SQS Alerts
#
# Emitted when Common Fate SQS is unhealthy
# By default, we only emit events on failed jobs.
######################################################

resource "aws_sns_topic" "sqs_alerts" {
  name         = "${var.namespace}-${var.stage}-sqs-alerts"
  display_name = "Common Fate deployment SQS alerts"
}

resource "aws_cloudwatch_metric_alarm" "sqs_queues_monitored_alarm" {
  alarm_name          = "${var.namespace}-${var.stage}-sqs-queues-monitored-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 5000
  alarm_description   = "Alarm when 100 messages are older than 5000 seconds for 2 consecutive periods"

  dimensions = {
    QueueName = "${var.namespace}-${var.stage}-event-queue"
  }

  alarm_actions = [aws_sns_topic.sqs_alerts.arn]
  ok_actions = [aws_sns_topic.sqs_alerts.arn]
}
