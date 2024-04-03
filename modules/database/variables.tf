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


variable "subnet_group_id" {
  description = "Specifies the ID of the subnet group for deployment."
  type        = string
}

variable "deletion_protection" {
  description = "Enables deletion protection for the RDS database."
  type        = bool
  default     = true
}

variable "apply_pitr_backup_rds" {
  description = "Override default behaviour and restore from a point in time backup. Must be used with restore_time"
  type        = bool
  default     = false

}

variable "pitr_restore_time" {
  description = "The date and time to restore from. Value must be a time in Universal Coordinated Time (UTC) format and must be before the latest restorable time for the DB instance."
  type        = string
  default     = null
}

variable "db_retention_period" {
  description = "The time between backups for the rds instance"
  type        = number
  default     = 0
}

