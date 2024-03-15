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


variable "certificate_arns" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the domains served by this load balancer"
  type        = list(string)

  validation {
    condition     = length(var.certificate_arns) > 0
    error_message = "The certificate_arns list must contain at least one certificate ARN."
  }
}


variable "public_subnet_ids" {
  description = "Lists the subnet IDs for public subnets."
  type        = list(string)
}

variable "use_internal_load_balancer" {
  description = "If 'true', the provisioned load balancer will be internal rather than external. Use this when you want to restrict network access to Common Fate to be behind a VPN only."
  default     = false
}
