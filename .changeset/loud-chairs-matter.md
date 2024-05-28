---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fix an issue where the S3 Audit Log Destination write role used a confusing tag. The role can now be tagged with 'common-fate-allow-assume-role=true' to allow Common Fate to assume it.
