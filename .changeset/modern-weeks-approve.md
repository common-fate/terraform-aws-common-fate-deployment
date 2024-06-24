---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes a cyclic reference issue when the ALB certificate ARN depends on the output of another Terraform module.
