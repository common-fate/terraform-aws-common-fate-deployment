---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Permit the control plane and worker task role to fetch the database secret from secrets manager. This change is implemented to support application layer database credential rotation support.
