---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue where the migration of users from Authz to the internal postgres database resulted in both names being set to the firstname in some cases.
