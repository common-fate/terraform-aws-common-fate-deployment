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


variable "rds_db_retention_period" {
  description = "The backup retention period for the RDS instance"
  type        = number
  default     = 7
}

variable "restore_to_point_in_time" {
  description = "Configuration block for restoring a DB instance to an arbitrary point in time"
  type = object(
    {
      restore_time                             = string
      source_db_instance_identifier            = string
      source_dbi_resource_id                   = string
      use_latest_restorable_time               = bool
      source_db_instance_automated_backups_arn = string

    }
  )
  default = null
}

variable "rds_multi_az" {
  description = "Enables RDS database to be deployed across multiple Availability Zones"
  type        = bool
  default     = true
}


variable "apply_immediately" {
  description = "Apply RDS changes immediately."
  type        = bool
  default     = true
}


variable "snapshot_identifier" {
  description = "(Optional) Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "rds_suffix" {
  description = "(Optional) adds a suffix to the database identifier"
  type        = string
  default     = null
}
