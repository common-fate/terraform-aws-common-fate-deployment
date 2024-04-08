---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Updates the built-in application version to v3.5.0, including the following changes:

Minor Changes
82f777b: Adds Preview User Access and Preview Entitlement Access (in beta) screens to the web app
5466d82: Adds Experimental APIS for PreviewUserAccess: list the entitlements a user can request and whether they need approval PreviewEntitlementAccess: list the users who can request access and whether they require approval QueryApprovers: list the approvers for an entitlement or a specific grant QueryEntitlements: Modified to use a cache and return whether the entitlement would be auto approved
Patch Changes
79e7e6e: Reduces max attempts for all background jobs by default to 5 which equates to a maximum interval time of ~4m20s between the 4th and 5th attempt. Previously, we used the default 25 retries which would leave tasks failing for potentially 3 weeks at most and they needed to be cancelled manually once the issue was resolved. Because our background tasks are mostly cron jobs that fetch data, it is desirable for the jobs not wait longer than the standard cron interval before retrying.
48b2449: Pager duty sync workflow will now skip syncing instead of returning an error when the integration is not yet configured.
ae4667b: Add an indicator for the requester in audit logs. Adds a fallback to show the email if the users name is empty.
c43824f: Fix an issue where the Access::Action::"Close" action was not applicable to the CF::Service entity type in the Cedar schema.
1a39150: Add support for configuring Slack channel message approve actions to open the request in the web app for review.
1640bbe: Adds a filter menu on the Access Request table for in progress requests. You can now filter by pending, active, requested, all.
