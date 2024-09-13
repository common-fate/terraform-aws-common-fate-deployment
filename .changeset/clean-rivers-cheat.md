---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Fixes an issue with GCP access de-provisioning where a request for multiple roles on the same target, such as a Project or Folder, could result in one of the roles not being removed when the request was closed.
