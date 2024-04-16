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
