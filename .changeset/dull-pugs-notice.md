---
"@common-fate/terraform-aws-common-fate-deployment": major
---

For BYOC customers: Removes the Authz service, which has been fully deprecated as of application version 4.3.0, has been removed from the infrastructure.
The supporting DynamoDB table for this service will remain until a future release when it will be removed.
