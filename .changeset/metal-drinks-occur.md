---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fix an issue where enabling IDP-initiated SAML SSO login would cause Terraform drift. You can now set the `saml_allow_idp_initiated_sign_in` variable to `true` to avoid configuration drift.
