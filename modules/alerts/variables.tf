variable "namespace" {
  description = "Specifies the namespace for the deployment."
  default     = "common-fate"
  type        = string
}

variable "alert_on_all_deployment_events" {
  description = "Set to 'true' to emit alerts for all deployment events, not just failures."
  default     = false
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
