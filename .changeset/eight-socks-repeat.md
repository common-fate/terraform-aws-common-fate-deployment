---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fix an issue where the `namespace`, `stage`, and `log_retention_in_days` variables were not propagated to the `ecs_base` module.
