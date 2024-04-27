---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Adds support for Managed Monitoring. When enabled, a Common Fate deployment will emit OpenTelemetry events to our centralised OpenTelemetry collector, allowing the Common Fate team to diagnose performance issues and proactively detect errors in your deployment. No identifiable information is included in the OpenTelemetry events.
