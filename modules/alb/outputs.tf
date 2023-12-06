######################################################
# Outputs
######################################################
output "domain" {
  description = "The domain name of the load balancer."
  value       = aws_lb.main_alb.dns_name
}

output "web_listener_arn" {
  description = "ARN of the load balancer web domain listener."
  value       = var.web_certificate_arn == "" ? null : aws_lb_listener.web_listener.arn
}

output "control_plane_listener_arn" {
  description = "ARN of the load balancer control plane domain listener."
  value       = var.control_plane_certificate_arn == "" ? null : aws_lb_listener.control_plane_listener.arn
}

output "authz_listener_arn" {
  description = "ARN of the load balancer authz domain listener."
  value       = var.authz_certificate_arn == "" ? null : aws_lb_listener.authz_listener.arn
}

output "access_handler_listener_arn" {
  description = "ARN of the load balancer access handler domain listener."
  value       = var.access_handler_certificate_arn == "" ? null : aws_lb_listener.access_handler_listener.arn
}

