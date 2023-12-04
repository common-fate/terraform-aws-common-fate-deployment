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
}

variable "aws_region" {
  description = "Determines the AWS Region for the deployment."
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


variable "access_handler_domain" {
  description = "The access handler domain (e.g., 'https://access.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.access_handler_domain))
    error_message = "The access_handler_domain must start with 'https://'."
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

variable "saml_provider_name" {
  description = "The name of the identity provider (e.g., 'Azure') displayed on the login screen."
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
