---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue where invalid configuration could cause the built-in Provisioner to report 'no provisioner has the capability to Grant <Role> on <Target>'. If you have a single provisioner registered with your Common Fate deployment, we'll always try and call it rather than reporting an error if the capabilities aren't correctly configured.
