---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Relax the AWS RDS database version constraint to be '15' rather than '15.4'. This fixes an issue where deployment updates could fail due to automatic minor version updates.
