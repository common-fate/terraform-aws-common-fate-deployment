---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Updates the built-in application version to v3.8.1, including the following changes:

Patch Changes
271ec76: Mitigates an issue where duplicate user identifiers may be created when a user first signs in to the web console.
d202dc5: Fix an issue where DataStax Organization Grant entities could not be found.
6026d2c: Fix an issue where available entitlements could be orphaned during integration resource syncing.
321de36: Fixes an issue where AWS RDS Instance to AWS Account edges would be removed during aws idc sync.
e3c139b: Users who are trying to approve access in Slack but have not yet signed in to Common Fate will now receive a more helpful error message.
2b8c2b1: Revert a breaking change to the json serialisation of eids in the SDK.
fda399c: Update background task runner to improve reliability and resilience to restarts while sync tasks are running. In some instances, tasks could be delayed from retrying for up to 2 hours after a restart.

Minor Changes
ae0d51b: A significant performance improvement to authorization.

Common Fate now stores integration data (such as AWS accounts, PagerDuty teams, and GCP projects) in the Control Plane database. Access Preview and List Entitlements APIs now use this data source, and are now served by the Control Plane service. The access preview and query entitlements apis have been updated to pull their data from the control plane. This brings a significant performance improvement. The authorization service remains unchanged.
