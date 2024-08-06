---
"@common-fate/terraform-aws-common-fate-deployment": major
---

Change the default VPC name for new deployments to include the namespace and stage params. In pre v3.0.0 the vpc was mistakingly created with a fixed name, this prevents multiple deployments being provisioned in the same AWS account. To fix this, a new variable has been added use_pre_3_0_0_vpc_name which shoudl be set to true for all existing deployments before upgrading to the new version.
