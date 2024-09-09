---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Adds permission checks to the integration page in the settings UI, this and other application configuration pages will only be viewable if the user has is an administrator or has a policy permitting the CF::Admin::Action::"Read" action.
