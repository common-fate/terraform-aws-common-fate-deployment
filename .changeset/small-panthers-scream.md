---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Updates the bundled Common Fate application release to be v2.1.0:

Adds support for Okta integration, adding user and group syncing and an Okta group provisioner

Update the provisioner configuration check to warn instead of panic when no provisioner types are configured
New users will have now have their identity linked with any idp integration upon logging in
Fix cleanup routine to remove closed requests that never started
Add expires timing to grants on request detail page
Prevent an internal server error when creating availability specs before resource syncing has run
