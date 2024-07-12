---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Entra SCIM integration now correctly handles the case where a group is a member of another group.
Previously all members of groups were treated as users, which meant that nested groups could not be used in access policies correctly.
