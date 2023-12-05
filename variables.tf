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

variable "aws_region" {
  description = "Determines the AWS Region for the deployment."
  type        = string
}

variable "release_tag" {
  description = "Specifies the tag for frontend and backend images, typically the git commit hash."
  type        = string
}

variable "app_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the API and frontend domains."
  type        = string
}

variable "auth_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the auth domain. Must be provisioned in us-east-1 for CloudFront."
  type        = string
}

variable "pager_duty_client_id" {
  description = "The private Pager Duty application client ID."
  default     = ""
  type        = string
}

variable "pager_duty_client_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the private Pager Duty application client secret."
  default     = ""
  type        = string
}

variable "slack_client_id" {
  description = "The private Slack application client ID."
  default     = ""
  type        = string
}

variable "slack_client_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the private Slack application client secret."
  default     = ""
  type        = string
}

variable "slack_signing_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the private Slack application signing secret."
  default     = ""
  type        = string
}

variable "auth_domain" {
  description = "The authorization domain (e.g., 'https://auth.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.auth_domain))
    error_message = "The auth_domain must start with 'https://'."
  }
}

variable "authz_domain" {
  description = "The authorization domain (e.g., 'https://authz.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.authz_domain))
    error_message = "The authz_domain must start with 'https://'."
  }
}

variable "web_domain" {
  description = "The frontend domain (e.g., 'https://mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.web_domain))
    error_message = "The web_domain must start with 'https://'."
  }
}

variable "api_domain" {
  description = "The API domain (e.g., 'https://api.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.api_domain))
    error_message = "The api_domain must start with 'https://'."
  }
}

variable "access_handler_domain" {
  description = "The access handler domain (e.g., 'https://access.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.access_handler_domain))
    error_message = "The access_handler_domain must start with 'https://'."
  }
}

variable "team_name" {
  description = "Specifies the team name used for branding on the frontend."
  default     = "Common Fate"
  type        = string
}

variable "favicon_url" {
  description = "Specifies a public favicon URL for frontend branding (e.g., 'https://commonfate.io/favicon.ico')."
  default     = "https://commonfate.io/favicon.ico"
  type        = string
}

variable "logo_url" {
  description = "Specifies a public logo URL for frontend branding."
  default     = "https://commonfate.io/logo.png"
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

variable "scim_token_ps_arn" {
  description = "The AWS Parameter Store ARN for the SCIM token."
  default     = ""
  type        = string
}

variable "licence_key_ps_arn" {
  description = "The AWS Parameter Store ARN for the license key."
  type        = string
}
