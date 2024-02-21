---
"@common-fate/teams": patch
---

Improves the formatting of log messages emitted by the 'authz' authorization service. Cedar authorizations are now logged to AWS CloudWatch, and you can now search CloudWatch logs for a particular Evaluation ID to find diagnostics for an authorization decision. The Evaluation ID is returned to end users if access is denied.
