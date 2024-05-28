---
"@common-fate/terraform-aws-common-fate-deployment": major
---

Removes the requirement to configure pager_duty_client_id, pager_duty_client_secret_ps_arn, slack_client_id, slack_client_secret_ps_arn, slack_signing_secret_ps_arn variables in the infrastructure layer. This configuration is now pulled directly from the integration config resources in your application configuration.
