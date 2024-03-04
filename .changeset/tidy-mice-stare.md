---
"@common-fate/terraform-aws-common-fate-deployment": minor
---
Updates the bundled Common Fate application release to be v2.2.0

Minor Changes
- Adds slack DM to the requestor when their request is approved, permits the activate and close request methods from withing Slack.

Patch Changes
- Fixes an issue where the web console would redirect to an invalid page after the Slack app install is complete.
- Improve grant state stepper so that Activated and Approved steps are correctly shown as skipped when a grant is closed before activation or appoval. Adds activatedAt and closedAt timestamps.
- Improves the UI of the 'integrations' section in the Settings page to indicate when integrations are loading, or when no integrations have been installed.
- Fixed issue causing closed requests to appear in in progress columns
- Improves the state management for Grants so that provisioning attempts are tracked. PReviously, a provisioning or network error would lead to a grant being incorrectly marked as active when the user may not actually have the access they requested. Failures in - - - provisioning will now result in grants ending in the pending state, allowing the use to retry activating.
- Handle cases in the AWS IDC provisioner where the entitlement has been removed outside of Common Fate, return successfully to prevent requests failing to close forever
- Fixed an error that occured when logging out
- fix audit logs not sorting chronologically
