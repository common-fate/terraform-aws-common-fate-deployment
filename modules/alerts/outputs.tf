######################################################
# Outputs
######################################################

// 'error_level_emitted_when' indicates the event which will trigger the alert if the default 'alert' variable is provided.
// 'info_level_emitted_when' indicates the events which will trigger the alert

output "alert_topics" {
  description = "SNS topic ARNs of alerts used for monitoring a Common Fate deployment"
  value = {
    deployment_failures = {
      emitted_when  = "An ECS deployment has failed"
      sns_topic_arn = aws_sns_topic.deployment_failures.arn
    }

    job_failures = {
      emitted_when  = "A background job has failed"
      sns_topic_arn = aws_sns_topic.job_failures.arn
    }
  }
}

// Topics that use the CloudWatch format for alerts
output "cloudwatch_alarm_topics" {
  description = "SNS topic ARNs of alerts for resources monitored with CloudWatch"
  value = {
    load_balancer_alerts = {
      emitted_when  = "Issues with the ALB load balancer"
      sns_topic_arn = aws_sns_topic.load_balancer_alerts.arn
    }

    database_alerts = {
      emitted_when  = "Issues with the database"
      sns_topic_arn = aws_sns_topic.database_alerts.arn
    }

    sqs_alerts = {
      emitted_when  = "Issues with SQS"
      sns_topic_arn = aws_sns_topic.sqs_alerts.arn
    }
  }
}
