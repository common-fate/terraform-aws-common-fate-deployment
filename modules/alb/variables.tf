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


variable "control_plane_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the control_plane_domain."
  type        = string
  default     = ""
}

variable "authz_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the authz_domain."
  type        = string
  default     = ""
}

variable "web_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the web_domain."
  type        = string
  default     = ""
}

variable "access_handler_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the access_handler_domain."
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "Lists the subnet IDs for public subnets."
  type        = list(string)
}
