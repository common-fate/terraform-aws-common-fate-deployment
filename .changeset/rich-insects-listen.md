---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Updates the built-in application version to v3.7.3, including the following changes:

Patch Changes
8323c0b: Fixes an issue where AWS RDS Instance to AWS Account edges would be removed during aws idc sync.
f42dcd7: Revert a breaking change to the json serialisation of eids in the SDK.
