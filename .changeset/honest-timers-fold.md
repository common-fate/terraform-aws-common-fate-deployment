---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Updates the built-in application version to v3.11.0 , including the following changes:

Minor Changes
5f64825: Adds additional OpenTelemetry attributes to authorization events.
2f1b875: Improves the performance of API authorization.
2a60d42: Workflows can now be configured with an activation expiry deadline to automatically close requests that have not been activated for a set period of time after being approved.
5d659e1: Adds support for Managed Monitoring. When enabled, OpenTelemetry traces are dispatched to Common Fate's centralised monitoring infrastructure to allow our team to proactively monitor your deployment. No identifiable information such as email addresses or cloud resource metadata is included in any monitoring events.

Patch Changes
d67388a: For BYOC customers: fixes an issue where event handler logs were noisy. Info-level logs have been shifted to Debug.
0831fdd: For BYOC customers: fixes an issue where error logs would be emitted during container shutdown.
b913687: Improve query performance for integration entities by using a more performant encoding strategy for attributes.
8e942aa: For BYOC customers: fixes OpenTelemetry API errors being included in spans with "An unexpected error has occured."
ff0b8d3: For BYOC customers: logs emitted when identities are not matched have been reduced to 'info' level rather than 'warn'.
3ffd115: For BYOC Customers: the Access Handler now connects to the Common Fate RDS database.
e13d669: Shows 'Approvers' as a column title in the Access Request detail table header.
8754da8: The web console now shows the Access Workflow name associated with a particular Access Request, when viewing the Access Request details.
ebc1d4c: Fix missing mapping of ListBackgroundJobKindSummary to Admin::Action::"Read" action.
45e1db0: Introduces improved authorization performance, available as an opt-in feature flag.
cfd0187: Adds Parents tab to the resource detail view in the web UI.
