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

variable "common_fate_aws_account_id" {
  description = "The ID or the account where Common Fate is deployed"
  type        = string
}

variable "external_id" {
  description = "The external id to be used for the IAM policy trust relation"
  type        = string
}


variable "regions" {
  description = "The AWS regions to deploy rds provisioning roles into."
  type        = list(string)
}


variable "organizational_unit_ids" {
  description = "The organization root ID or organizational unit (OU) IDs to which StackSets deploys the rds provisioning role into"
  type        = list(string)
}

