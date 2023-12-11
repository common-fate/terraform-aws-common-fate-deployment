######################################################
# Outputs
######################################################

output "first_time_setup_config" {
  description = "Values to use when finishing the initial Common Fate deployment process"
  value = {
    dns_cname_record_for_app_domain  = module.alb.domain
    dns_cname_record_for_auth_domain = module.cognito.user_pool_cloudfront_distribution
    saml_sso_entity_id               = module.cognito.saml_entity_id
    saml_sso_acs_url                 = module.cognito.saml_acs_url
  }
}

output "cognito_saml_entity_id" {
  description = "The cognito entity ID required for SAML configuration"
  value       = module.cognito.saml_entity_id
}

output "cognito_saml_acs_url" {
  description = "The cognito ACS URL required for SAML configuration"
  value       = module.cognito.saml_acs_url
}

output "load_balancer_domain" {
  description = "The load balancer domain required for configuring DNS records to point to the frontend and api service"
  value       = module.alb.domain
}


output "user_pool_cloudfront_distribution" {
  description = "The cloudfront domain of the cognito user pool required for configuring dns records for the auth domain"
  value       = module.cognito.user_pool_cloudfront_distribution
}

output "web_client_id" {
  description = "web client id"
  value       = module.cognito.web_client_id
}

output "cli_client_id" {
  description = "cli client id"
  value       = module.cognito.cli_client_id
}

output "terraform_client_id" {
  description = "terraform client id"
  value       = module.cognito.terraform_client_id
}

output "terraform_client_secret" {
  description = "terraform client secret"
  value       = module.cognito.terraform_client_secret
  sensitive   = true
}

output "control_plane_task_role_arn" {
  description = "The control plane task role arn."
  value       = module.control_plane.task_role_arn
}

output "access_handler_security_group_id" {
  description = "The access handler security group id."
  value       = module.access_handler.security_group_id
}

output "vpc_id" {
  description = "The vpc id."
  value       = module.vpc.vpc_id
}


output "private_subnet_ids" {
  description = "The private subnet id."
  value       = module.vpc.private_subnet_ids
}


output "ecs_cluster_id" {
  description = "The ecs id."
  value       = module.ecs.cluster_id
}
