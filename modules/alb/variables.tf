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
  description = "Specifies the ID of the Virtual Private Cloud (VPC)."
  type        = string
}


variable "certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the domains served by this load balancer"
  type        = string
}

variable "additional_certificate_arns" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the domains served by this load balancer"
  type        = set(string)
  default     = []
}


variable "public_subnet_ids" {
  description = "Lists the subnet IDs for public subnets."
  type        = list(string)
}

variable "use_internal_load_balancer" {
  description = "If 'true', the provisioned load balancer will be internal rather than external. Use this when you want to restrict network access to Common Fate to be behind a VPN only."
  default     = false
}

variable "maintenance_mode_enabled" {
  description = "If 'true', the ALB will return a fixed response indicating that Common Fate is in maintenance mode."
  type        = bool
  default     = false
}

variable "maintenance_mode_message" {
  description = "The message to display when maintenance mode is enabled. This can be overridden to provide a custom maintenance message."
  type        = string
  default     = "Common Fate is currently down for maintenance. You can get in touch with us at support@commonfate.io."
}
