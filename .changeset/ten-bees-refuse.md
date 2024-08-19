---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Built-in roles can now be requested using the JIT request workflow with access governed by cedar policies. For new deployments, an initial policy is created which permits access to the administrative role. In existing deployments, no default access is create, teams can add the cedar policy to expose this role if required.
