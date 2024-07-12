---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Common Fate users are now proactively provisioned for our Slack, AWS IAM Identity Center, and PagerDuty integrations. Common Fate user accounts will be created automatically for user accounts in these integrations.

This fixes an issue where users would have to wait for an initial integration resource sync before they could request access to entitlements.
