---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Updates the bundled Common Fate application release to be v2.3.2:

### Minor Changes

d1e6cf7: Adds deployment diagnostics. You can fetch diagnostic information about your Common Fate deployment by running the cf deployment diagnostics command.
This command requires the caller to have permissions to execute CF::Control::DiagnosticService::Action::"GetOAuthTokenMetadata".

0261674: Added DataStax integration.

### Patch Changes

6f463a9: Fix issue causing access request flow to get stuck in broken state.
Fix issue causing some attributes not to show for resources.

5ad3a57: Fixes and issue which prevented using keyboard navigation correctly in the access request UI in the web app when selecting an entitlement

cfc0974: Update Slack Oauth scopes to match the app definition, fixes an issue causing slack commands not to show for SaaS customers

e9841a4: Requesting access in the UI will now display the duration of the request in the preflight

99d9b55: Fixes an issue which may have caused PagerDuty sync to fail for some teams

f9e9b4c: Adds DataStax integration icons to the web console UI.
