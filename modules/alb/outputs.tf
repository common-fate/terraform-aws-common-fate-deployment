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


output "alb_security_group_id" {
  description = "the id for the security group managing the alb"
  value = aws_security_group.alb_sg.id
}
