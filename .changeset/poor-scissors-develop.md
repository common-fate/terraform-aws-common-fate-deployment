---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue where provisioning would fail for S3 bucket access when a provisioner webhook was configured in the config but not with the dynamic access capability.
