resource "aws_s3_bucket" "main" {
  bucket_prefix = var.bucket_prefix
  force_destroy = var.force_destroy

  tags = local.default_tags
}
