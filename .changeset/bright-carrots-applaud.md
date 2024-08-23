---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue where email casing was not ignored in the connected identities sync which could result in duplicate users being created and identities not being linked correctly.
