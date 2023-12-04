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
  description = "Specifies the Amazon Certificate Manager (ACM) certificate ARN."
  type        = string
}

variable "public_subnet_ids" {
  description = "Lists the subnet IDs for public subnets."
  type        = list(string)
}
