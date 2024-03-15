---
"@common-fate/terraform-aws-common-fate-deployment": major
---

Minor Changes
51db74c: Adds the ability to add multiple slack clients for different slack tenancies. As well as sending slack messages to different channels
7329afa: Updates the SCIM implementation to fix an issue which would cause users to be created with their first name repeated.
Adds support for resetting the Entra users which were created via SCIM, so that they can be reset in the event that the SCIM configuration was incorrect.
5c7014b: Adds additional metadata to authorization evaluations, including authorization duration.
Patch Changes
cd3d1e4: Improve the target field of slack messages by including the target tye
aaf54f7: Fix an infinite rerender bug on the resources pages that could be triggered by using the breadcrumb navigation
cd3d1e4: Fix an issue which caused auto approved requests to have approval buttons in slack channel messages
cd3d1e4: Fix an issue where activating a request from the CLI would not update the slack DM
51db74c: When a slack integration is removed from terraform it will be uninstalled from the slack workspace and tokens will be removed.
f511e30: Use a background task to update availabilities on demand when selectors or availability specs are updated in terraform configuration. Ensuring access is made unavailable shortly after the update.
