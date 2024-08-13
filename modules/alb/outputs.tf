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
  value       = aws_security_group.alb_sg.id
}
output "load_balancer_arn" {
  description = "ARN of the load balancer."
  // make downstream modules depend on the https listener being deployed before attempting to use this ARN
  // For example, this means the ECS tasks will need to wait for the listerner being attached before creating target groups
  value = aws_lb_listener.https_listener.load_balancer_arn
}

output "alb_arn_suffix" {
  description = "The arn suffix of the load balancer"
  value       = aws_lb.main_alb.arn_suffix
}
