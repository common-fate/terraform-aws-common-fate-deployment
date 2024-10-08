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

variable "aws_region" {
  description = "The AWS region the module is being deployed to"
  type        = string
}


variable "aws_account_id" {
  description = "The AWS account ID the module is being deployed to"
  type        = string
}

variable "ecs_cluster_id" {
  description = "The ARN of the ECS Cluster"
  type        = string
}


variable "event_bus_name" {
  description = "The Common Fate EventBridge event bus name"
  type        = string
}

variable "alert_metadata" {
  description = "Metadata to include in alerts emitted by Common Fate. Will be included in the 'metdata' field in the JSON alert payload."
  type        = any
  nullable    = true
  default     = null
}

variable "alb_arn_suffix" {
  description = "The arn suffix of the load balancer"
  type        = string
}

variable "control_plane_tg_arn_suffix" {
  description = "The arn suffix of the control plane target group"
  type        = string
}

variable "db_instance_identifier" {
  description = "The instance identifier of the database"
  type        = string
}

variable "sqs_queue_name" {
  description = "The sqs queue name"
  type        = string
}
