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
  description = "Specifies the ID of the Virtual Private Cloud (VPC) for deployment."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the IDs of the subnets for deployment."
  type        = list(string)
}

variable "subnet_group_id" {
  description = "Specifies the ID of the subnet group for deployment."
  type        = string
}
