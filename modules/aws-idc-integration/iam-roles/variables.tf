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

variable "common_fate_aws_reader_role_arn" {
  type = string
}

variable "common_fate_aws_provisioner_role_arn" {
  type = string
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

