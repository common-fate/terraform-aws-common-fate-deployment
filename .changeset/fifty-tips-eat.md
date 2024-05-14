---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

@common-fate/teams@3.13.0
Minor Changes
03bdf87: For BYOC customers: adds OpenTelemetry instrumentation of write operations to DynamoDB.
bdc4db3: Adds support for requiring a reason on Access Requests.
cd49fa1: Added ListProfiles api to be used with Granted for filling ~/.aws/config with Common Fate profiles
85a21e6: Added support for setting default durations on Access Workflows.
Patch Changes
0512476: Centralised support can now be disabled by setting a variable in CF Terraform deployment module
9477ed6: Fix entity not found errors for Grant types on the Authorization Log page in the web app.
47c6a7b: Fix to Slack interactivity causing 500 errors when activating or closing requests
46781fd: Fixes an issue where users could not access AWS immediately after logging in for the first time.
5502339: Fixes an issue causing Auth0 resource syncing to fail due to a permissions error.
8c154d5: Fix an issue where user names were not shown in the web console Access Request list.
b4dd0d0: For BYOC customers: reduces the severity on the error-level log if deprovisioning is skipped to be info-level.
fd55c30: Improve configuration API integrity and performance
3679361: Improve the robustness of database migrations. Common Fate can now handle deployment rollbacks where migrations have been run.
f1a6ee8: Fix an issue which could cause active grants to be revoked if the activation expiry is exceeded.
bcc3240: Format durations and timestamps in resource view to be human readable.
8bf869d: Add the environment variable CF_FORCE_CONFIG_MIGRATIONS to enable forced migration of configurations for optional fields.
7a06805: Set the Default Duration to the Access Duration if not initially configured.
bbbdaaf: For BYOC customers: allow disabling automatic database migrations when the Control Plane container starts.
