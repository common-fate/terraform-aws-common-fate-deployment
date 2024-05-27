---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Update bundled application version to v4.0.0

Major Changes
6505c33: For BYOC customers, removes the dependency on the authz service and the underlying DynamoDB table for all APIs. API performance is improved and overal running costs are reduced.
Minor Changes
95d2486: Adds deep linking to the AWS console. After requesting access to an entitlement, clicking the 'open URL' button will open the AWS console with the requested account and role.
2ec349f: You can now select multiple Access Requests in the web console to approve or close all of them at once.
Patch Changes
69e8eb4: Use default duration instead of max duration for grant expiry when no duration is supplied in the request.
49340a6: Fix an issue where the Auth0 integration icon was not correctly displayed in the web console settings page.
eef2f72: Fix an issue where account name whitespace was not properly removed when using Common Fate as a Granted Profile Registry backend.
21c710b: Adds CF::Service::"ReadOnly" with permissions to access the Schema and Policy APIs
9b9f64a: For BYOC customers: fixes the formatting of the error log when duplicate users are found.
2da33aa: Sets the name on Datastax users to their email.
32e6ca4: Adds the ability to customise the AWS IAM Identity Center start URL used with the built-in AWS Profile Registry. To customise this, specify the sso_access_portal_url variable in the commonfate_aws_idc_integration resource.
608cb10: Fix an issue where Auth0 access tokens were not refreshed.
6505c33: Fix Debugger UI not showing a user if their name is not set.
33973eb: Remove access grants, access requests and audit logs from the resources API.
ae50f5c: Disable approve button if approve action is not available to the user.
93b2fec: Add Access Request justification to webhook events
