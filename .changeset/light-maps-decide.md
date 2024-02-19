---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fix the auth_url variable being incorrectly propagated to the web console module in the case where the default Cognito sign in URL is used.
