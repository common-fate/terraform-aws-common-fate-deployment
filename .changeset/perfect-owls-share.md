---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Updates the built-in application version to v3.7.0, including the following changes:

Minor Changes

34ac234: The Common Fate Control Plane now additionally writes integration data (such as AWS accounts, PagerDuty teams, and GCP projects) to it's internal database. This is an internal change to make way for some planned authorization performance improvements.
