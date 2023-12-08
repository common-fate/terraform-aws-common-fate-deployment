######################################################
# Outputs
######################################################


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

output "provisioner_url" {
  description = "The provisioner URL to be used when configuring webhook connectors in configuration"
  value       = module.provisioner.provisioner_url
}

output "gcp_read_role_arn" {
  description = "The gcp read role arn"
  value       = module.gcp_workload_identity_roles.read_role_arn
}

output "gcp_provision_role_arn" {
  description = "The gcp provision role arn"
  value       = module.gcp_workload_identity_roles.provision_role_arn
}
