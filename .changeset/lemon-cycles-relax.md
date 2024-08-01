---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue when updating the path of a secret from PagerDuty or Slack during setup, the complete setup URL would point to an integration ID which does not exist, requiring you to remove and recreate the resource in terraform.
