---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Minor Changes
Adds support for reducing the duration of access when making an Access Request.
Patch Changes
Matching user accounts in integrations via email address is now case-insensitive.
Slack DM is always sent for requests which originate from Slack, improving the user experience.
Improve the readability of the target selector list when making an access request via the web console.
Adds an icon for the Okta integration in the settings page.
Fix an issue where querying for grant output data (used in the Common Fate AWS RDS integration) would return an empty result
Fixes an issue which caused the Common Fate Audit Log API to return some logs in non-deterministic order when they are created with the same timestamp. Logs now have an additional 'index' field which tracks the order they are created.
Identity syncing workflows will now use the key "detail" instead of "error" in warning logs when a user from an external integration cannot be linked to an internal CF::User. This change reduces noise when filtering logs for errors.
Security fix: GraphQL API introspection is now disabled by default.
