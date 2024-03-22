---
"@common-fate/terraform-aws-common-fate-deployment": patch
---

Updates the default Docker image repositories to use ECR Public repositories rather than DockerHub. This mitigates rate limiting issues observed with the DockerHub repositories. Our ECR Public repository namespace is `public.ecr.aws/z2x0a3a1/common-fate-deployment`.
