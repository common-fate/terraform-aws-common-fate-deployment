---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Minor Changes
We've made a small change to Cedar authorization in preparation for releasing Cedar policy analysis tooling. The Cedar resource used for authorizing the Access::Action::"Request" action is now the Access::Availability entity, rather than the Access::Grant entity. This is a non-breaking change and existing Cedar policies will continue to behave identically.
Patch Changes
Fix issue causing multiple availabilities to be shown in the availability query
web app will now display any diagnostic information on the grants from the preflight request in the overview page
Adds the application version to the settings page in the web app.
Add empty state to pending access requests table.
Add empty state for resources pages in the web app.
Reduce the verbosity of error messages emitted by the graphql API and correctly assign error codes.
Adds the release tag for the application into the loggers for the services.
Move cleanup workflow into using river queues
