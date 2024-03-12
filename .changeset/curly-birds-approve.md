---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Update the bundled Common Fate application release to be v3.0.0

### Major Changes

e128940: Splits background workflows out into database backed work queue.

### Minor Changes

d1e6cf7: Adds deployment diagnostics. You can fetch diagnostic information about your Common Fate deployment by running the `cf deployment diagnostics` command.This command requires the caller to have permissions to execute `CF::Control::DiagnosticService::Action::"GetOAuthTokenMetadata"`.
44dfad5: Added DataStax integration

### Patch Changes

45a493e: Adds additional rate limit handling to OpsGenie resource syncing.
3e9e52d: Fix issue causing access request flow to get stuck in broken state.Fix issue causing some attributes not to show for resources.
0914d4e: Fixes an issue which caused the grants to show the message "Error Processing Grant" after a preflight in the Web App when the grant was already active or pending in another request.
c449aa7: Fixes and issue which prevented using keyboard navigation correctly in the access request UI in the web app when selecting an entitlement
cfc0974: Update Slack Oauth scopes to match the app definition, fixes an issue causing slack commands not to show for SaaS customers
080018a: Adds retry handle to accommodate opsgenie ratelimit errors in OpsGenie integration
387c99d: Requesting access in the UI will now display the duration of the request in the preflight
0914d4e: Encode the reason into the URL query params for the access request form
b3d8785: Adds DataStax integration icons to the web console UI.
5f5e582: Fixes an issue which may have caused PagerDuty sync to fail for some teams
