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

variable "single_nat_gateway" {
  default     = false
  description = "Should be true if you want to provision a single shared NAT Gateway for the deployment."
}


variable "one_nat_gateway_per_az" {
  default     = true
  description = "Should be false if you want to provision a single shared NAT Gateway for the deployment."
}
variable "vpc_name_suffix" {
  description = "In cases where you need to deploy more than one Common Fate stack intothe same account, the VPC will need to be suffixed."
  type        = string
  default     = ""
}
