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

variable "ecs_deployment_alerts_webhooks_subscription_urls" {
  description = "A list of webhook urls to subscribe to the ecs-deployment-alerts SNS topic"
  default     = []
  type        = list(string)
}


variable "ecs_cluster_arn" {
  description = "The ECS Cluster ARN"
  type        = string
}
