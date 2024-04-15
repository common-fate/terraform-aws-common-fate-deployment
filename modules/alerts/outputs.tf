######################################################
# Outputs
######################################################

// 'error_level_emitted_when' indicates the event which will trigger the alert if the default 'alert' variable is provided.
// 'info_level_emitted_when' indicates the events which will trigger the alert

output "alert_topics" {
  description = "SNS topic ARNs of alerts used for monitoring a Common Fate deployment"
  value = {
    deployments = {
      errors_emitted_when = "An ECS deployment has failed"
      all_emitted_when    = "An ECS deployment state has changed"
      sns_topic_arn       = aws_sns_topic.deployments.arn
    }

    jobs = {
      errors_emitted_when = "A background job has failed"
      all_emitted_when    = "A background job has finished"
      sns_topic_arn       = aws_sns_topic.jobs.arn
    }
  }
}
