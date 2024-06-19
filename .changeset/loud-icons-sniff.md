---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes a permissions issue which prevented the provisioner from reading secrets from SSM Parameter store at runtime, for integrations such as Okta, Entra, Auth0
