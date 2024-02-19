# @common-fate/terraform-aws-common-fate-deployment

## 1.13.1

### Patch Changes

- 2ec15ec: The Assume Role External ID is now set to `null` by default, rather than being a required (but nullable) variable.

## 1.13.0

### Minor Changes

- 7a609e6: Introduce stacksets for deploying audit and rds roles, migrate to using tag based assume role policy conditions for control plane and provisioner.
- eefebfb: A default application release tag is now specified as part of the Terraform module. If you've been using the `release_tag` parameter, you should now remove this parameter from the stack to use the application versions bundled with the Terraform module.

  The initial bundled application release is v1.3.1.

- 47d06e6: Adds modules required for Least Privilege Analysis. This module adds an S3 bucket used to store analysis reports.

### Patch Changes

- 713855f: Relax the AWS RDS database version constraint to be '15' rather than '15.4'. This fixes an issue where deployment updates could fail due to automatic minor version updates.
- 714a2c3: Add lifecycle ignore_changes blocks for uncontrolled values on cognito saml_idp and stacksets to prevent update warnings that don't make any changes

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
