---
"@common-fate/terraform-aws-common-fate-deployment": major
---

For BYOC customers: Removes the Authz service, which has been fully deprecated as of application version 4.3.0.
The supporting DynamoDB table for this service will remain until a future release when it will be removed.
Th CloudWatch log group for the Authz service will remain until a future release when it will be removed.
