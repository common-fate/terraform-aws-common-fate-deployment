---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Improvements to permissions of the IAM Identity Center integration module:

- `iam:UpdateSAMLProvider` is no longer required by default, and is only added if `permit_management_account_assignments` is set to `true`.
- When `permit_management_account_assignments` is true, adds some additional policy statements to prevent edge cases such as a Permission Set's description being updated
- Where possible, aligns the `Sid` field on the provisioner statements to match `AWSSSOServiceRolePolicy`.
