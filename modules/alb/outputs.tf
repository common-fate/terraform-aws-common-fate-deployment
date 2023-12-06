######################################################
# Outputs
######################################################
output "domain" {
  description = "The domain name of the load balancer."
  value       = aws_lb.main_alb.dns_name
}

output "listener_arn" {
  description = "ARN of the load balancer listener."
  value       = aws_lb_listener.https_listener.arn
}

