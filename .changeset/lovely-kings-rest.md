---
"@common-fate/teams": patch
---

Fixes a race condition in the web UI which could cause duplicate core users (CF::User resources) to be created upon initial login.
