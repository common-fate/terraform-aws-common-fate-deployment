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

output "outputs" {
  description = "All outputs from the Common Fate module"
  value = {
    dns_cname_record_for_app_domain  = module.alb.domain
    dns_cname_record_for_auth_domain = module.cognito.user_pool_cloudfront_distribution
    saml_sso_entity_id               = module.cognito.saml_entity_id
    saml_sso_acs_url                 = module.cognito.saml_acs_url
    web_client_id                    = module.cognito.web_client_id
    cli_client_id                    = module.cognito.cli_client_id
    terraform_client_id              = module.cognito.terraform_client_id
    provisioner_client_id            = module.cognito.provisioner_client_id
    control_plane_task_role_arn      = module.control_plane.task_role_arn
    access_handler_security_group_id = module.access_handler.security_group_id
    vpc_id                           = module.vpc.vpc_id
    private_subnet_ids               = module.vpc.private_subnet_ids
    ecs_cluster_id                   = module.ecs.cluster_id
    auth_issuer                      = module.cognito.auth_issuer
    event_bus_log_group_name         = module.events.event_bus_log_group_name
    cognito_user_pool_id             = module.cognito.user_pool_id
    cognito_identity_provider_name   = module.cognito.identity_provider_name
    provisioner_task_role_arn        = module.provisioner.task_role_arn
     provisioner_task_role_name        = module.provisioner.task_role_name
    provisioner_url                  = module.provisioner.provisioner_url
  }
}


output "sensitive_outputs" {
  description = "Sensitive output values such as generated OIDC client secrets"
  sensitive   = true
  value = {
    terraform_client_secret   = module.cognito.terraform_client_secret
    provisioner_client_secret = module.cognito.provisioner_client_secret
  }
}

output "provisioner_task_role_arn" {
  description = "The task role arn of the builtin provisioner module"
  value       = module.provisioner.task_role_arn
}

output "provisioner_task_role_name" {
  description = "The task role name of the builtin provisioner module"
  value       = module.provisioner.task_role_name
}

output "provisioner_url" {
  description = "The private ecs url of provisioner module"
  value       = module.provisioner.provisioner_url
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

output "provisioner_client_id" {
  description = "provisioner client id"
  value       = module.cognito.provisioner_client_id
}

output "provisioner_client_secret" {
  description = "provisioner client secret"
  value       = module.cognito.provisioner_client_secret
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
output "auth_issuer" {
  description = "The auth issuer."
  value       = module.cognito.auth_issuer
}
output "event_bus_log_group_name" {
  description = "The Event Bus log group name."
  value       = module.events.event_bus_log_group_name
}

output "alb_listener_arn" {
  description = "The ALB Listener ARN."
  value       = module.alb.listener_arn
}

output "auth_authority_url" {
  description = "The OIDC authority URL."
  value       = module.cognito.auth_authority_url
}

output "alb_security_group_id" {
  description = "The ALB Security Group ID."
  value       = module.alb.alb_security_group_id
}

output "cognito_identity_provider_name" {
  description = "The Cognito identity provider name."
  value       = module.cognito.identity_provider_name
}


output "cognito_user_pool_id" {
  description = "The Cognito user pool ID."
  value       = module.cognito.user_pool_id
}
