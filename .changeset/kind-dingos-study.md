---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fix an issue where the Common Fate CLI would generate an invalid `credential_process` profile field for AWS accounts with names containing whitespace.
