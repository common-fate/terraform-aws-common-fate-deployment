######################################################
# Outputs
######################################################

output "event_bus_arn" {
  description = "The event bus arn"
  value       = aws_cloudwatch_event_bus.event_bus.arn
}

output "sqs_queue_arn" {
  description = "The sqs queue arn"
  value       = aws_sqs_queue.event_queue.arn
}

output "sqs_queue_name" {
  description = "The sqs queue name"
  value       = aws_sqs_queue.event_queue.name
}

