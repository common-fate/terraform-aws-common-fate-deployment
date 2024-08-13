variable "namespace" {
  description = "Specifies the namespace for the deployment."
  default     = "common-fate"
  type        = string
}

variable "stage" {
  description = "Defines the stage of the deployment (e.g., 'dev', 'staging', 'prod')."
  default     = "prod"
  type        = string
}

variable "auth_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the auth domain. Must be provisioned in us-east-1 for CloudFront. Provide this and the auth_url to configure cognito with a custom domain."
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "Determines the AWS Region for the deployment."
  type        = string
}

variable "auth_url" {
  description = "The custom auth url (e.g., 'https://auth.mydomain.com'). Provide this and the auth_certificate_arn to configure cognito with a custom domain."
  type        = string
  default     = ""
}


variable "app_url" {
  description = "The app url (e.g., 'https://common-fate.mydomain.com')."
  type        = string
}

variable "saml_provider_name" {
  description = "The name of the identity provider (e.g., 'Entra') displayed on the login screen."
  default     = ""
  type        = string
}

variable "saml_metadata_is_file" {
  description = "Determines if the 'saml_metadata_source' is a file path or a URL. Set to true for a file, false for a URL."
  default     = false
  type        = bool
}

variable "saml_metadata_source" {
  description = "Specifies the URL or file path for the SAML metadata."
  default     = ""
  type        = string
}

variable "web_access_token_validity_duration" {
  description = "Specifies how long the access token in the web Cognito client will be valid for. Unit is specified in `web_oidc_token_validity_units` and is in minutes by default."
  default     = 10
  type        = number
}

variable "web_refresh_token_validity_duration" {
  description = "Specifies how long the refresh token in the web Cognito client will be valid for.  Unit is specified in `web_oidc_token_validity_units` and is in days by default."
  default     = 30
  type        = number
}

variable "web_access_token_validity_units" {
  description = "Specifies the duration unit used for the 'web_access_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "minutes"
}

variable "web_refresh_token_validity_units" {
  description = "Specifies the duration unit used for the 'web_refresh_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "days"
}

variable "cli_access_token_validity_duration" {
  description = "Specifies how long the access token in the CLI Cognito client will be valid for. Unit is specified in `web_oidc_token_validity_units` and is in minutes by default."
  default     = 60
  type        = number
}

variable "cli_refresh_token_validity_duration" {
  description = "Specifies how long the refresh token in the CLI Cognito client will be valid for.  Unit is specified in `web_oidc_token_validity_units` and is in days by default."
  default     = 30
  type        = number
}

variable "cli_access_token_validity_units" {
  description = "Specifies the duration unit used for the 'cli_access_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "minutes"
}

variable "cli_refresh_token_validity_units" {
  description = "Specifies the duration unit used for the 'cli_refresh_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "days"
}
variable "invite_user_emails" {
  description = "Comma separated list of user emails to create in the default Cognito user pool, an invite email will be sent with details for logging in."
  default     = ""
  type        = string
}
