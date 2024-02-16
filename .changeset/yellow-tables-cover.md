---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Add lifecycle ignore_changes blocks for uncontrolled values on cognito saml_idp and stacksets to prevent update warnings that don't make any changes
