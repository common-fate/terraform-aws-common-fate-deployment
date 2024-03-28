---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Patch Changes
when updating a workflow in config a worker task will be run to update availabilities based onff any changes made to the workflow
Fixes an issue which would cause Entra Users synced by scim not to be correctly related to CF::Users leading to policies not working as expected.
for BYOC customers: improves logging in aws IAM Identity Center sync workflow
