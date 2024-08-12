
######################################################
# Cognito User Pool
######################################################
resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "${var.namespace}-${var.stage}-cognito-user-pool"

  // disables self serve signup
  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_subject = "You've been invited to Common Fate"
      email_message = local.inviteEmailTemplate
      // sms is unused but terraform forces it to be defined
      sms_message = "Your username is {username}. Sign in at {####} "
    }
  }

  lifecycle {
    ignore_changes = [schema]
  }

}




resource "aws_cognito_identity_provider" "saml_idp" {
  count         = length(var.saml_provider_name) > 0 && length(var.saml_metadata_source) > 0 ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.cognito_user_pool.id
  provider_name = var.saml_provider_name
  provider_type = "SAML"

  attribute_mapping = {
    email       = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
    family_name = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/familyname",
    given_name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
  }

  provider_details = var.saml_metadata_is_file ? {
    MetadataFile = file(var.saml_metadata_source)
    } : {
    MetadataURL = var.saml_metadata_source
  }
  lifecycle {
    ignore_changes = [
      provider_details["ActiveEncryptionCertificate"],
      provider_details["SLORedirectBindingURI"],
      provider_details["SSORedirectBindingURI"]
    ]
  }

}

// default to cognito when saml is not yet configured
locals {
  identity_provider_name = length(var.saml_provider_name) > 0 ? var.saml_provider_name : "COGNITO"
}
resource "aws_cognito_user_pool_client" "web-app-client" {
  name         = "${var.namespace}-${var.stage}-web-app-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  # The following should be configured based on your requirements:
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  allowed_oauth_flows          = ["code"]
  supported_identity_providers = [local.identity_provider_name]
  default_redirect_uri         = "${var.app_url}/auth/callback"

  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false
  allowed_oauth_scopes                 = ["openid", "profile", "email"]
  callback_urls                        = ["${var.app_url}/auth/callback"]
  logout_urls                          = ["${var.app_url}/logout"]
  depends_on                           = [aws_cognito_identity_provider.saml_idp]
  access_token_validity                = var.web_access_token_validity_duration
  refresh_token_validity               = var.web_refresh_token_validity_duration
  token_validity_units {
    access_token  = var.web_access_token_validity_units
    refresh_token = var.web_refresh_token_validity_units
  }
}



resource "aws_cognito_user_pool_client" "cli_client" {
  name         = "${var.namespace}-${var.stage}-cli-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  # The following should be configured based on your requirements:
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  allowed_oauth_flows          = ["code"]
  supported_identity_providers = [local.identity_provider_name]
  default_redirect_uri         = "http://localhost:18900/auth/callback"

  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false
  allowed_oauth_scopes                 = ["openid", "profile", "email"]
  callback_urls                        = ["http://localhost:18900/auth/callback"]
  depends_on                           = [aws_cognito_identity_provider.saml_idp]

  access_token_validity  = var.cli_access_token_validity_duration
  refresh_token_validity = var.cli_refresh_token_validity_duration
  token_validity_units {
    access_token  = var.cli_access_token_validity_units
    refresh_token = var.cli_refresh_token_validity_units
  }
}


resource "aws_cognito_resource_server" "resource_server" {
  identifier   = "cf.client"
  name         = "${var.namespace}-${var.stage}-resource-server"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  scope {
    scope_name        = "machine"
    scope_description = "machine to machine read write access"
  }
}


resource "aws_cognito_user_pool_client" "terraform_client" {
  name         = "${var.namespace}-${var.stage}-terraform-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity                = 8
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource_server.scope_identifiers
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "read_only_client" {
  name         = "${var.namespace}-${var.stage}-read-only-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity                = 8
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource_server.scope_identifiers
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true
}


resource "aws_cognito_user_pool_client" "provisioner_client" {
  name         = "${var.namespace}-${var.stage}-provisioner-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity                = 8
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource_server.scope_identifiers
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true
}


resource "aws_cognito_user_pool_client" "control_plane_service_client" {
  name         = "${var.namespace}-${var.stage}-control-plane-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity                = 8
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource_server.scope_identifiers
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true
}

resource "aws_cognito_user_pool_client" "slack_service_client" {
  name         = "${var.namespace}-${var.stage}-slack-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity                = 8
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource_server.scope_identifiers
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true
}



resource "aws_cognito_user_pool_client" "access_handler_service_client" {
  name         = "${var.namespace}-${var.stage}-access-handler-client"
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity                = 8
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.resource_server.scope_identifiers
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = true
}

// generates a friendly name like "cf-auth-gentle-shad" to be used as the cognito auth prefix when a custom domain is not in use
resource "random_pet" "auth_domain_prefix" {
  prefix = "cf-auth"
}
locals {
  has_custom_domain = var.auth_url != "" && var.auth_certificate_arn != ""
}
// Optionally configure a custom domain if the auth_url and auth_certificate_arn are provided
resource "aws_cognito_user_pool_domain" "custom_domain" {
  domain          = local.has_custom_domain ? replace(var.auth_url, "https://", "") : random_pet.auth_domain_prefix.id
  user_pool_id    = aws_cognito_user_pool.cognito_user_pool.id
  certificate_arn = local.has_custom_domain ? var.auth_certificate_arn : null
}


locals {
  // the initial users to create is a comma seperated list, split and trim any whitespace
  initial_user_emails = toset(compact([for email in split(",", var.initial_user_emails) : trim(email, " ")]))
}
resource "aws_cognito_user" "initial_users" {
  for_each     = local.initial_user_emails
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  username     = each.value
  attributes = {
    email = each.value
  }
  // send notifications via email only
  desired_delivery_mediums = ["EMAIL"]
}
