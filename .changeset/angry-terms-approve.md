---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Updates the bundled Common Fate application release to be v2.0.1:

- Improves the formatting of log messages emitted by the 'authz' authorization service. Cedar authorizations are now logged to AWS CloudWatch, and you can now search CloudWatch logs for a particular Evaluation ID to find diagnostics for an authorization decision. The Evaluation ID is returned to end users if access is denied.

- Fixes a race condition in the web UI which could cause duplicate core users (CF::User resources) to be created upon initial login.

- Fixes an issue where the requestor was not visible in the Access Request detail view.

- Fixes an issue which could cause resource sync workflows to hang.
