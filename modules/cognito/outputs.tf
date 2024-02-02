######################################################
# Outputs
######################################################

output "saml_entity_id" {
  description = "The Cognito entity ID required for SAML configuration."
  value       = "urn:amazon:cognito:sp:${aws_cognito_user_pool.cognito_user_pool.id}"
}

output "saml_acs_url" {
  description = "The Cognito Assertion Consumer Service (ACS) URL required for SAML configuration."
  value       = "${var.auth_url}/saml2/idpresponse"
}

output "user_pool_cloudfront_distribution" {
  description = "The CloudFront domain of the Cognito user pool, required for configuring DNS records for the auth domain."
  value       = aws_cognito_user_pool_domain.custom_domain.domain
}

output "user_pool_id" {
  description = "The ID of the Cognito user pool."
  value       = aws_cognito_user_pool.cognito_user_pool.id
}

output "auth_authority_url" {
  description = "The authentication URL for the Cognito user pool."
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.cognito_user_pool.id}/"
}

output "auth_issuer" {
  description = "The issuer URL for authentication, associated with the Cognito user pool."
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.cognito_user_pool.id}"
}

output "web_client_id" {
  description = "The client ID for web-based authentication."
  value       = aws_cognito_user_pool_client.web-app-client.id
}

output "cli_client_id" {
  description = "The client ID for Command Line Interface (CLI) authentication."
  value       = aws_cognito_user_pool_client.cli_client.id
}

output "terraform_client_id" {
  description = "The client ID for Terraform authentication."
  value       = aws_cognito_user_pool_client.terraform_client.id
}

output "terraform_client_secret" {
  description = "The client secret for Terraform authentication."
  value       = aws_cognito_user_pool_client.terraform_client.client_secret
}
output "provisioner_client_id" {
  description = "The client ID for Provisioner authentication."
  value       = aws_cognito_user_pool_client.provisioner_client.id
}

output "provisioner_client_secret" {
  description = "The client secret for Provisioner authentication."
  value       = aws_cognito_user_pool_client.provisioner_client.client_secret
}




output "control_plane_service_client_id" {
  description = "The client ID for the control plane service."
  value       = aws_cognito_user_pool_client.control_plane_service_client.id
}

output "control_plane_service_client_secret" {
  description = "The client secret for the control plane service."
  value       = aws_cognito_user_pool_client.control_plane_service_client.client_secret
}

output "access_handler_service_client_id" {
  description = "The client ID for the access handler service."
  value       = aws_cognito_user_pool_client.access_handler_service_client.id
}

output "access_handler_service_client_secret" {
  description = "The client secret for the access handler service."
  value       = aws_cognito_user_pool_client.access_handler_service_client.client_secret
}
