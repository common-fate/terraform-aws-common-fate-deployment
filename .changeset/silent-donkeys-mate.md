---
"@common-fate/terraform-aws-common-fate-deployment": major
---

For BYOC Customers: This change removes the provisioner config variables from the infrastructure stack. To upgrade, you will need to remove any references to these variables in your config. The provisioner is now configured entirely from the application configuration.
