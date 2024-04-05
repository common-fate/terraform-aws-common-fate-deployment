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


variable "rds_restore_to_point_in_time_restore_time" {
  description = "The date and time to restore from. Value must be a time in Universal Coordinated Time (UTC) format and must be before the latest restorable time for the DB instance."
  type        = string
  default     = null
}

variable "db_retention_period" {
  description = "The backup retention period for the RDS instance"
  type        = number
  default     = 0
}


variable "rds_restore_to_point_in_time_source_db_instance_identifier" {
  description = "The date and time to restore from. Value must be a time in Universal Coordinated Time (UTC) format and must be before the latest restorable time for the DB instance."
  type        = string
  default     = null
}

variable "restore_to_point_in_time" {
  description = "nested block: NestingList, min items: 0, max items: 1"
  type = set(object(
    {
      restore_time                  = string
      source_db_instance_identifier = string
      source_dbi_resource_id        = string
      use_latest_restorable_time    = bool
    }
  ))
  default = []
}
