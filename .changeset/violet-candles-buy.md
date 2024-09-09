---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

The AWS RDS Proxy integration has been overhauled to seperate database configuration from the proxy infrastructure. This change improves the reliability of the AWS proxy and makes it easier to configure where teams have databases deployed in different terraform stacks.

This is a breaking change for the AWS RDS Proxy, teams using the previous version of the proxy will need to redeploy the proxy and add databases as seperate modules in terraform.
