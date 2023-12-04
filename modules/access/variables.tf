variable "namespace" {
  description = "Specifies the namespace for the deployment."
  default     = "common-fate"
  type        = string
}

variable "stage" {
  description = "Determines the deployment stage (e.g., 'dev', 'staging', 'prod')."
  default     = "prod"
  type        = string
}

variable "vpc_id" {
  description = "Specifies the ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the subnet IDs for deployment."
  type        = list(string)
}

variable "eventbus_arn" {
  description = "Specifies the Amazon EventBridge (formerly CloudWatch Events) EventBus ARN."
  type        = string
}

variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}

variable "release_tag" {
  description = "Defines the tag for frontend and backend images, typically a git commit hash."
  type        = string
}

variable "authz_domain" {
  description = "Specifies the authorization domain (e.g., 'https://authz.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.authz_domain))
    error_message = "The authz_domain must start with 'https://'."
  }
}

variable "auth_authority_url" {
  description = "Specifies the URL used for authentication."
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

variable "access_handler_domain" {
  description = "Defines the domain for access handler (e.g., 'https://access.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.access_handler_domain))
    error_message = "The access_handler_domain must start with 'https://'."
  }
}

variable "auth_issuer" {
  description = "Specifies the issuer for authentication."
  type        = string
}
