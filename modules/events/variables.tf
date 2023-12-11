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
variable "log_retention_in_days" {
  description = "Specifies the cloudwatch log retention period for events."
  default     = 365
  type        = number
}
