---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

The Resources tab and APIs are now gated behind the action CF::Directory::Action::"GetResource" which is part of the CF::Admin::Action::"Read" action group. Users without these permissions will no longer be able to view this page.
