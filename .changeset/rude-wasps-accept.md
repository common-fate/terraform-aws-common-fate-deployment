---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue where the access handler would skip deprovisioning RDS proxy access in cases where the proxy config had been changed while a grant was active. Now, regardless of the config changing, the access handler will always attempt to remove the Permission Set that was created to grant access.
