terraform {
  required_providers {
    deploymeta = {
      source  = "common-fate/deploymeta"
      version = "0.2.0"
    }
  }
}

locals {
  app_domain = "console.${data.deploymeta_deployment.this.default_subdomain}.${data.deploymeta_deployment.this.dns_zone_name}"
}

provider "deploymeta" {
  deployment_name = "commonfate"
  licence_key     = var.licence_key
}

data "deploymeta_deployment" "this" {}

resource "aws_acm_certificate" "this" {
  domain_name       = local.app_domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "deploymeta_dns_record" "automatic_cert_validation" {
  zone_name = data.deploymeta_deployment.this.dns_zone_name
  name      = tolist(aws_acm_certificate.start.domain_validation_options)[0].resource_record_name
  values    = [tolist(aws_acm_certificate.start.domain_validation_options)[0].resource_record_value]
  type      = tolist(aws_acm_certificate.start.domain_validation_options)[0].resource_record_type
}

resource "deploymeta_dns_record" "app_domain" {
  zone_name = data.deploymeta_deployment.this.dns_zone_name
  name      = "${local.app_domain}."
  values    = [var.alb_domain]
  type      = "CNAME"
}
