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

// This has been deprecated in favour of using tag based assume role policies
variable "common_fate_aws_reader_role_arn" {
  description = "Deprecated: Use common_fate_aws_account_id instead"
  type = string
  default = ""
}

// This has been deprecated in favour of using tag based assume role policies
variable "common_fate_aws_provisioner_role_arn" {
  description = "Deprecated: Use common_fate_aws_account_id instead"
  type = string
  default = ""
}

variable "permit_management_account_assignments" {
  description = "By default, the AWS IAM role for the provisioner does not have the required permissions to assign access to the organization management account. You can enable that feature with this flag set to true"
  type        = bool
  default     = false
}

variable "permit_group_assignment" {
  description = "By default, the AWS IAM role for the provisioner does not have the required permissions to manage IAM Identity Center group memberships. You can enable that feature with this flag set to true"
  type        = bool
  default     = false
}
variable "permit_provision_permission_sets" {
  description = "By default, the AWS IAM role for the provisioner does not have the required permissions to create and delete Permission Sets. You can enable that feature with this flag set to true"
  type        = bool
  default     = false
}

variable "common_fate_aws_account_id" {
  description = "The ID or the account where Common Fate is deployed"
  type        = string
  default     = "" // Optional to avoid breaking changes, in future we can make this required
}

variable "assume_role_external_id" {
  description = "The external id to be used for the IAM policy trust relation"
  type        = string
  default     = ""
}
