locals {
  # Compound Scope Identifier
  csi = replace(
    format(
      "%s-%s-%s-%s",
      var.namespace,
      var.stage,
      var.component,
      var.bucket_prefix,
    ),
    "_",
    "",
  )

  # CSI for use in resources with a global namespace, i.e. S3 Buckets
  csi_global = replace(
    format(
      "%s-%s-%s-%s-%s-%s",
      var.namespace,
      var.aws_account_id,
      var.region,
      var.stage,
      var.component,
      var.bucket_prefix,
    ),
    "_",
    "",
  )

  default_tags = merge(
    var.default_tags,
    {
      Module = var.module
      Name   = var.bucket_prefix
    },
  )
}
