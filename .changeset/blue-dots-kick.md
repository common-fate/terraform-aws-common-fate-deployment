---
"@common-fate/teams": patch
---

The Access::Action::"ForceClose" action will now only be evaluated if the force close option is provided in the API request. This change reduces excess policy authorization noise in the authorization log for authorization results that are never used.
