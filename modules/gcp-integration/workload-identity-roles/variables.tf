variable "gcp_project" {
  type = string
}

variable "common_fate_aws_account_id" {
  type = string
}

variable "gcp_organization_id" {
  type = string
}

variable "common_fate_aws_reader_role_name" {
  type    = string
  default = "common-fate-prod-control-plane-ecs-tr"
}

variable "common_fate_aws_provisioner_role_name" {
  type    = string
  default = "common-fate-prod-provisioner-ecs-tr"
}
