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
  description = "Additional certificate ARNs to add to the load balancer"
  type        = list(string)
}


variable "public_subnet_ids" {
  description = "Lists the subnet IDs for public subnets."
  type        = list(string)
}
