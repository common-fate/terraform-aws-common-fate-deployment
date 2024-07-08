---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue in the Service Connect configuration which was causing a 15 second timeout. This would cause access requests to fail in some instances when multiple entitlements were requested.
