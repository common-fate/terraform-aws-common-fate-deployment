---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Updates the bundled application version to be v3.4.4, including the following changes:

### Patch changes

6f3ffbf: Fixes an issue where Cedar policy validation would return a warning for entity identifiers including a '/' character.

a4210c7: Fixes an issue with the Cedar schema where an "Action" suffix was used in some namespaces.

For example, CF::Control::Integration::Reset::ResetService::Action::Action::"GetOAuthTokenMetadata" is now fixed to be CF::Control::Integration::Reset::ResetService::Action::"GetOAuthTokenMetadata".

a4210c7: Fixes an issue with the Common Fate Cedar schema, where the PagerDuty::User entity type was not a member of the PagerDuty::OnCall entity.

ae20f85: Fixes an issue where Access Request validation would cause the 'Reason' field to freeze in the web console.

6f8ede2: Fixes the formatting of advice in the permission denied message

6f3ffbf: Updates the included Cedar version to be v3.1.2. This is a minor update and there are no breaking changes to Cedar policies.
