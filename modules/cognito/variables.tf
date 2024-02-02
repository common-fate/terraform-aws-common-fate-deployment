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
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the auth domain. Must be provisioned in us-east-1 for CloudFront."
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "Determines the AWS Region for the deployment."
  type        = string
}

variable "auth_url" {
  description = "The auth url (e.g., 'https://auth.mydomain.com')."
  type        = string
  default     = ""

  validation {
    condition     = var.auth_url == "" ? true : can(regex("^https://", var.auth_url))
    error_message = "The auth_url must start with 'https://'."
  }
}
variable "cognito_auth_domain_prefix" {
  description = "If you are not using a custom domain, provide a prefix such as your team name. e.g common-fate. Domain prefixes may only include lowercase, alphanumeric characters, and hyphens. You can't use the text aws, amazon, or cognito in the domain prefix. Your domain prefix must be unique within the current Region."
  type        = string

}

variable "app_url" {
  description = "The app url (e.g., 'https://common-fate.mydomain.com')."
  type        = string

  # validation {
  #   condition     = can(regex("^https://", var.app_url))
  #   error_message = "The app_url must start with 'https://'."
  # }
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
