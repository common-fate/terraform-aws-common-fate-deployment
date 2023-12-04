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

variable "vpc_id" {
  description = "Specifies the ID of the Virtual Private Cloud (VPC)."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the IDs of the subnets."
  type        = list(string)
}

variable "release_tag" {
  description = "Defines the tag for frontend and backend images, typically a git commit hash."
  type        = string
}

variable "frontend_domain" {
  description = "Specifies the frontend domain (e.g., 'https://mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.frontend_domain))
    error_message = "The frontend_domain must start with 'https://'."
  }
}

variable "api_domain" {
  description = "Specifies the API domain (e.g., 'https://api.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.api_domain))
    error_message = "The api_domain must start with 'https://'."
  }
}

variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}

variable "auth_domain" {
  description = "Specifies the authentication domain (e.g., 'https://auth.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.auth_domain))
    error_message = "The auth_domain must start with 'https://'."
  }
}

variable "authz_domain" {
  description = "Specifies the authorization domain (e.g., 'https://authz.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.authz_domain))
    error_message = "The authz_domain must start with 'https://'."
  }
}

variable "team_name" {
  description = "Specifies the team name for branding the frontend."
  type        = string
}

variable "favicon_url" {
  description = "Specifies a public URL for the favicon used in frontend branding (e.g., 'https://commonfate.io/favicon.ico')."
  type        = string
}

variable "logo_url" {
  description = "Specifies a public URL for the logo used in frontend branding."
  type        = string
}

variable "auth_authority_url" {
  description = "Specifies the URL used for authentication."
  type        = string
}

variable "auth_web_client_id" {
  description = "Specifies the client ID for web authentication."
  type        = string
}

variable "auth_cli_client_id" {
  description = "Specifies the client ID for CLI authentication."
  type        = string
}

variable "ecs_cluster_id" {
  description = "Identifies the Amazon Elastic Container Service (ECS) cluster for deployment."
  type        = string
}

variable "alb_listener_arn" {
  description = "Specifies the Amazon Load Balancer (ALB) listener ARN."
  type        = string
}
