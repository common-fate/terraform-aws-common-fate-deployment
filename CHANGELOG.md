# @common-fate/terraform-aws-common-fate-deployment

## 1.20.0

### Minor Changes

- d8e94f7: Updates the bundled Common Fate application release to be v2.3.2:

  ### Minor Changes

  d1e6cf7: Adds deployment diagnostics. You can fetch diagnostic information about your Common Fate deployment by running the cf deployment diagnostics command.
  This command requires the caller to have permissions to execute CF::Control::DiagnosticService::Action::"GetOAuthTokenMetadata".

  0261674: Added DataStax integration.

  ### Patch Changes

  6f463a9: Fix issue causing access request flow to get stuck in broken state.
  Fix issue causing some attributes not to show for resources.

  5ad3a57: Fixes and issue which prevented using keyboard navigation correctly in the access request UI in the web app when selecting an entitlement

  cfc0974: Update Slack Oauth scopes to match the app definition, fixes an issue causing slack commands not to show for SaaS customers

  e9841a4: Requesting access in the UI will now display the duration of the request in the preflight

  99d9b55: Fixes an issue which may have caused PagerDuty sync to fail for some teams

  f9e9b4c: Adds DataStax integration icons to the web console UI.

- 799ccf5: Adds environment variables and provisioner configuration for Common Fate's DataStax integration.

## 1.19.0

### Minor Changes

- 5bdb669: Fixed task_role_name output for provisioner module
- f1bda70: Add additional input to the provisioner module allowing additional security groups to have ingress. Permit the control plane ingress on the builtin provisioner.
- fa55bb2: Updates the bundled Common Fate application release to be v2.2.0

  Minor Changes

  - Adds slack DM to the requestor when their request is approved, permits the activate and close request methods from withing Slack.

  Patch Changes

  - Fixes an issue where the web console would redirect to an invalid page after the Slack app install is complete.
  - Improve grant state stepper so that Activated and Approved steps are correctly shown as skipped when a grant is closed before activation or appoval. Adds activatedAt and closedAt timestamps.
  - Improves the UI of the 'integrations' section in the Settings page to indicate when integrations are loading, or when no integrations have been installed.
  - Fixed issue causing closed requests to appear in in progress columns
  - Improves the state management for Grants so that provisioning attempts are tracked. Previously, a provisioning or network error would lead to a grant being incorrectly marked as active when the user may not actually have the access they requested. Failures in provisioning will now result in grants ending in the pending state, allowing the use to retry activating.
  - Handle cases in the AWS IDC provisioner where the entitlement has been removed outside of Common Fate, return successfully to prevent requests failing to close forever
  - Fixed an error that occured when logging out
  - fix audit logs not sorting chronologically

## 1.18.0

### Minor Changes

- 382c1ce: Updates the bundled Common Fate application release to be v2.1.1:

  - Adds an additional check to ensure that user emails are included in the SAML assertion when SAML SSO is used. This fixes an issue where users appear with an empty email address if SAML SSO is misconfigured.
  - Add additional validation to the authorization service to prevent resources with empty Entity IDs (EIDs) being written to the database.
  - Fixes an issue where resource names were not propagated into Slack Access Request messages.

## 1.17.1

### Patch Changes

- 6938182: Add additional missing external ID environment variables for aws provisioners

## 1.17.0

### Minor Changes

- ca94e45: Adds support for Okta integration configuration
- 778160b: Updates the bundled Common Fate application release to be v2.1.0:

  Adds support for Okta integration, adding user and group syncing and an Okta group provisioner

  Update the provisioner configuration check to warn instead of panic when no provisioner types are configured
  New users will have now have their identity linked with any idp integration upon logging in
  Fix cleanup routine to remove closed requests that never started
  Add expires timing to grants on request detail page
  Prevent an internal server error when creating availability specs before resource syncing has run

### Patch Changes

- ec5bb85: Expose variables single_nat_gateway and one_nat_gateway_per_az on the vpc module to enable deploying with a single nat gateway instance.

## 1.16.2

### Patch Changes

- a75d182: - 1c4757d: Add iam:GetRole to provisioner for AWS IAM IDC org root account access

## 1.16.1

### Patch Changes

- e7d9221: Improvements to permissions of the IAM Identity Center integration module:

  - `iam:UpdateSAMLProvider` is no longer required by default, and is only added if `permit_management_account_assignments` is set to `true`.
  - When `permit_management_account_assignments` is true, adds some additional policy statements to prevent edge cases such as a Permission Set's description being updated
  - Where possible, aligns the `Sid` field on the provisioner statements to match `AWSSSOServiceRolePolicy`.

## 1.16.0

### Minor Changes

- ab38e22: Update the AWS IDC Roles module to support an AWS account principal and external ID

## 1.15.0

### Minor Changes

- dc50d9e: Updates the bundled Common Fate application release to be v2.0.1:

  - Improves the formatting of log messages emitted by the 'authz' authorization service. Cedar authorizations are now logged to AWS CloudWatch, and you can now search CloudWatch logs for a particular Evaluation ID to find diagnostics for an authorization decision. The Evaluation ID is returned to end users if access is denied.

  - Fixes a race condition in the web UI which could cause duplicate core users (CF::User resources) to be created upon initial login.

  - Fixes an issue where the requestor was not visible in the Access Request detail view.

  - Fixes an issue which could cause resource sync workflows to hang.

## 1.14.1

### Patch Changes

- 0de75fe: Fix auth_url and acs_url output for cognito module which was incorrectly formed when a custom domain was not configured.
- 10a3609: Add additional missing Read policies to the optional AWS IDC Provisioner role

## 1.14.0

### Minor Changes

- 7194206: Updates the bundled Common Fate application release to be v2.0.0. Common Fate v2.0.0 contains an updated web console UI with an easier access request workflow and built-in dark mode support.

### Patch Changes

- 6a921e3: Fix the auth_url variable being incorrectly propagated to the web console module in the case where the default Cognito sign in URL is used.

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
