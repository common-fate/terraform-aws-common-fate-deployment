---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue where Cedar policies for Access::Action::"Request" which restricted the resource to a specific type of entitlement would cause no entitlements to be available for request.
