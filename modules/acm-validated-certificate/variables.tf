variable "domain" {
  type        = string
  description = "The domain to provision the certificate for"
}

variable "zone_id" {
  type        = string
  description = "The Route53 hosted zone ID"
}
