---
"@common-fate/teams": minor
---

The retention for authorization events (visible in the "Authorization" page in the web console) is now 1 year by default. After the retention period, events will be removed from the Common Fate database. For BYOC customers, events will still be present in CloudWatch, depending on the retention period you have configured for your log group.
