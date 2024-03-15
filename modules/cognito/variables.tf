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
  description = "Specifies how long the access token in the web cognito client will be valid for. Unit is in minutes"
  default     = 10
  type        = number
}

