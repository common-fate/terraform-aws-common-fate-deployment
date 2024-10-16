---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Added multistep approval conditions to access workflows. You can now optionally configure 1 or more conditions which must be met for a Grant to be approved. Each approval must be completed by a seperate reviewer, for example require approval from both the engineering and security teams. Where no approval steps are defined, the existing behaviour is preserved, a Grant will be marked as approved when any permitted principal approvs the request.
