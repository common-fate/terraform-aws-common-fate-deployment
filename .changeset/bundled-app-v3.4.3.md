---
"@common-fate/terraform-aws-common-fate-deployment": minor
---

Updates the bundled application version to be v3.4.3, including the following changes:

### Patch changes

ff84578: Fix an issue preventing automatic approvals being processed when a user requested access using certain conditions. Specifically, the issue was encountered when using Cedar policies similar to the below:

```
permit (
    principal,
    action == Access::Action::"Activate",
    resource in GCP::Folder::"folders/12345"
);
```

In application version v3.4.2, we changed some entity types in preparation for adopting Cedar schemas. The resource being acted upon above is the GCP::ProjectGrant entity. In v3.4.2, the GCP::ProjectGrant was not correctly made to be a child of GCP::Folder::"folders/12345". The effect of this is that the authorization engine would 'fail closed' and deny an automatic approval. This release fixes this issue - we've also updated our internal test suite to cover these types of Cedar policies to prevent this issue from occurring in future.

a29f794: Fix an issue preventing users from retrieving Cedar schemas due to a default authorization check.
