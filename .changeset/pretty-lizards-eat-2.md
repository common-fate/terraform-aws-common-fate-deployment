---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Updates the bundled Common Fate application version to v3.3.0, including the following changes:

- Minor Changes

  - Adds a log viewer and debugger for authorization evaluations

- Patch Changes
  - (For BYOC deployments) fixes a formatting issue in the error log emitted in the event a Common Fate worker cannot reach the database.
  - The Access Request list is now shown at the /access/requests URL, rather than /access. The /access URL will automatically redirect you to the correct page.
  - Browser tab titles in the web console show a descriptive name based on the current page you're viewing.
  - Fix an issue where Common Fate background tasks could stop running when database credentials were automatically rotated
  - Fix an issue preventing the "Closed" Access Requests tab from opening in the Common Fate web console.
