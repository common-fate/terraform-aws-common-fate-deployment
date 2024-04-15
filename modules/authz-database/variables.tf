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
variable "dynamodb_restore_date_time" {
  description = "Time of the point-in-time recovery point to restore."
  type        = string
  default     = null

}

variable "dynamodb_restore_source_name" {
  description = "Name of the table to restore. Must match the name of an existing table."
  type        = string
  default     = null


}
variable "dynamodb_restore_to_latest_time" {
  description = "If set, restores table to the most recent point-in-time recovery point."
  type        = bool
  default     = null


}
