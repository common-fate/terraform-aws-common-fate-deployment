######################################################
# Outputs
######################################################
output "cognito_saml_entity_id" {
  description = "The cognito entity ID required for SAML configuration"
  value       = module.common-fate.cognito_saml_entity_id
}

output "cognito_saml_acs_url" {
  description = "The cognito ACS URL required for SAML configuration"
  value       = module.common-fate.cognito_saml_acs_url
}

output "load_balancer_domain" {
  description = "The load balancer domain required for configuring DNS records to point to the frontend and api service"
  value       = module.common-fate.load_balancer_domain
}


output "user_pool_cloudfront_distribution" {
  description = "The cloudfront domain of the cognito user pool required for configuring dns records for the auth domain"
  value       = module.common-fate.user_pool_cloudfront_distribution
}

output "web_client_id" {
  description = "web client id"
  value       = module.common-fate.web_client_id
}

output "cli_client_id" {
  description = "cli client id"
  value       = module.common-fate.cli_client_id
}

output "terraform_client_id" {
  description = "terraform client id"
  value       = module.common-fate.terraform_client_id
}

output "terraform_client_secret" {
  description = "terraform client secret"
  value       = module.common-fate.terraform_client_secret
  sensitive   = true
}

output "provisioner_url" {
  description = "The provisioner URL to be used when configuring webhook connectors in configuration"
  value       = module.provisioner.provisioner_url
}
output "control_plane_task_role_arn" {
  description = "The control plane task role arn"
  value       = module.common-fate.control_plane_task_role_arn
}
