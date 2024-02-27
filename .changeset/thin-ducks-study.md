---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Updates the bundled Common Fate application release to be v2.1.1:

- Adds an additional check to ensure that user emails are included in the SAML assertion when SAML SSO is used. This fixes an issue where users appear with an empty email address if SAML SSO is misconfigured.
- Add additional validation to the authorization service to prevent resources with empty Entity IDs (EIDs) being written to the database.
- Fixes an issue where resource names were not propagated into Slack Access Request messages.
