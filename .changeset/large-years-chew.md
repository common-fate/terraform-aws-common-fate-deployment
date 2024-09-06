---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Removes the hardcoded AWS provider block in the module. Fixes an issue where the module could not be destroyed due to the provider block being present.
