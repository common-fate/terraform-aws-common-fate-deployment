
######################################################
# Cognito User Pool
######################################################
resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "${var.namespace}-${var.stage}-cognito-user-pool"
  // disables self serve signup
  admin_create_user_config {
    allow_admin_create_user_only = true
  }
  lambda_config {
    pre_token_generation = aws_lambda_function.pre_token_generation_lambda_function.arn
  }
}


data "archive_file" "lambda" {
  type                    = "zip"
  source_content_filename = "preTokenGenerationLambda.js"
  source_content          = <<EOT
exports.handler = async (event) => {
  event.response = {
    claimsOverrideDetails: {
      claimsToAddOrOverride: {
        appUrl: process.env.APP_URL,
      },
    },
  };
  return event;
};
EOT
  output_path             = "pre_token_generation_function.zip"
}
resource "aws_cloudwatch_log_group" "pre_token_gen_lambda_lg" {
  name              = "/aws/lambda/${var.namespace}-${var.stage}-pre-token-generation"
  retention_in_days = 14

}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.namespace}-${var.stage}-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_policy" "pre_token_gen_lambda_logging_policy" {
  name        = "${var.namespace}-${var.stage}-pre_token_gen_lambda-logging-policy"
  description = "Allow Lambda to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = aws_cloudwatch_log_group.pre_token_gen_lambda_lg.arn
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "pre_token_gen_lambda_logs_attachment" {
  policy_arn = aws_iam_policy.pre_token_gen_lambda_logging_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}
resource "aws_lambda_permission" "cognito_permission" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_token_generation_lambda_function.function_name
  principal     = "cognito-idp.amazonaws.com"
 
}

resource "aws_lambda_function" "pre_token_generation_lambda_function" {
  function_name    = "${var.namespace}-${var.stage}-pre-token-generation"
  filename         = "pre_token_generation_function.zip"
  handler          = "preTokenGenerationLambda.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  role             = aws_iam_role.lambda_exec_role.arn
  timeout          = 10
  environment {
    variables = {
      APP_URL = var.app_url
    }
  }
}

resource "aws_cognito_user_pool_domain" "custom_domain" {
  domain          = replace(var.auth_url, "https://", "")
  user_pool_id    = aws_cognito_user_pool.cognito_user_pool.id
  certificate_arn = var.auth_certificate_arn
}

resource "aws_cognito_identity_provider" "saml_idp" {
  count         = length(var.saml_provider_name) > 0 && length(var.saml_metadata_source) > 0 ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.cognito_user_pool.id
  provider_name = var.saml_provider_name
  provider_type = "SAML"

  attribute_mapping = {
    email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
  }

  provider_details = var.saml_metadata_is_file ? {
    MetadataFile = file(var.saml_metadata_source)
    } : {
    MetadataURL = var.saml_metadata_source
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
