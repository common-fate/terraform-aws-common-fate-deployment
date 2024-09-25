---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes the default value for the 'rds_instance_identifier_suffix' variable, to fix an error: 'The expression result is null' when applying the Terraform stack.
