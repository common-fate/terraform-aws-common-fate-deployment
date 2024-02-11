# @common-fate/terraform-aws-common-fate-deployment

## 1.12.0

### Minor Changes

- c9d5291: Deploy a provisioner as part of the main stack

### Patch Changes

- c9d5291: Add https:// prefix back to cognito outputs after custom domain change
- c9d5291: Fix the cognito module typo for the random_pet module

## 1.11.0

### Minor Changes

- 8854a39: Remove the requirement for deploying with a custom auth domain, drop the pre token generation lambda

## 1.10.0

### Minor Changes

- 1ac549b: IAM Identity Center integration: adds optional permissions to allow management of group memberships
- 8184a23: Adds variables to customise API URLs and CORS allowed origins

### Patch Changes

- 33efd74: Fixes an issue where the default logo URL pointed to a broken image if a custom logo wasn't provided for the deployment

## 1.9.0

### Minor Changes

- 8bfad52: Add rds deletion protection and remove old security groups

## 1.8.0

### Minor Changes

- b06c410: Apply security fixes from trivy scanner where applicable. Add trivy ignore annotations where applicable.
