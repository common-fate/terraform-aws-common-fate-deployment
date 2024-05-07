---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Minor Changes
8b3a0e2: Adds support for requesting access to a GCP Role Group. A Role Group is a group of multiple roles which are requested and assigned together. GCP Role Groups allow you to work around the permission count restriction in custom roles.
e5f4200: Adds Auth0 integration.
5ad1121: Updates API for slack alerts to allow for configuring messages via direct message to approvers
Patch Changes
3d84d18: For BYOC customers: fixes an issue where the 'version' attribute on OpenTelemetry spans was not being set.
b949ed9: Fixes name based lookups for target and role when using the CLI to ensure access when the embedded authorization feature flag is enabled.
bd49b98: Fix an issue where auto-approved access would use a lower priority Access Workflow, if the Access Workflow had a longer duration.
7ec033c: Improve performance of the integration APIs
8fb8815: Fix an issue causing the duration input to reset when requesting access in the web console.
6cfc525: Fixes an issue where invalid configuration could cause the built-in Provisioner to report 'no provisioner has the capability to Grant on '. If you have a single provisioner registered with your Common Fate deployment, we'll always try and call it rather than reporting an error if the capabilities aren't correctly configured.
691ea97: Performance improvement for the Availability Maker background process.
b7a83a4: Fix an issue on the new request page which would cause the access duration to reset when the reason was updated.
