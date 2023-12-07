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

variable "name" {
  description = "A short name to identify the cloud provider that these roles will be connected to. E.g 'gcp'"
  type        = string
}

variable "grant_principals_read_access" {
  description = "A list of AWS principals to grant assume role access on the read role"
  type        = list(string)
}

variable "grant_principals_provision_access" {
  description = "A list of AWS principals to grant assume role access on the provision role"
  type        = list(string)
}
