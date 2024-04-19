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

variable "workload_identity_pool_id" {
  type    = string
  default = "common-fate-gcp"
}

variable "workload_identity_pool_display_name" {
  type    = string
  default = "Common Fate"
}

variable "workload_identity_pool_provider_id" {
  type    = string
  default = "common-fate-aws-deployment"
}

variable "workload_identity_pool_provider_display_name" {
  type    = string
  default = "Common Fate AWS"
}


variable "gcp_reader_iam_role_id" {
  type    = string
  default = "commonfate.read"
}

variable "gcp_reader_service_account_id" {
  type    = string
  default = "common-fate-gcp-read"
}


variable "gcp_provisioner_iam_role_id" {
  type    = string
  default = "commonfate.provision"
}

variable "gcp_provisioner_service_account_id" {
  type    = string
  default = "common-fate-gcp-provision"
}

variable "permit_bigquery_provisioning" {
  type    = bool
  default = false
}

variable "permit_organization_provisioning" {
  type    = bool
  default = false
}
