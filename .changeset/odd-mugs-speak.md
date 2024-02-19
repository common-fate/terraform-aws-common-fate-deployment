---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

A default application release tag is now specified as part of the Terraform module. If you've been using the `release_tag` parameter, you should now remove this parameter from the stack to use the application versions bundled with the Terraform module.

The initial bundled application release is v1.3.1.
