---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue that could lead to a denial of service with the policy API if a malformed or forbid all policy was created. The CF::Service::"Terraform" which is service principal assumed by the terraform client credentials is now always permitted to use the policy APIs regardless of the customer policies applied, preventing customers from being unable to revert a bad policy change.
