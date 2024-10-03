# @common-fate/terraform-aws-common-fate-deployment

## 2.6.3

### Patch Changes

- 9a043ad: Fixes an issue which could cause terraform operations to hang when querying selectors.

## 2.6.2

### Patch Changes

- 11a71a4: Fixes the default value for the 'rds_instance_identifier_suffix' variable, to fix an error: 'The expression result is null' when applying the Terraform stack.

## 2.6.1

### Patch Changes

- 2c6a525: Fixes an issue causing expiry notifications to not be sent
- 2c6a525: Replace filter dropdown menus on the all requests page with filter chips which can be used to construct more complex queries. Requests can be filtered by requestor, approver, closer, and for multiple principals at the same time.
- 2c6a525: Only create the default admin access role policy for new managed deployments.
- 820a2ef: Add managed_deployment variable to apply additional configuration on initial deployment.
- 2c6a525: Fixed RDS database and user names not showing on the get and list request APIs.
- 2c6a525: Fix issue causing empty AWS start url when using RDS proxy functionality with connected identities enabled.
- 2c6a525: Fixes the position of the bulk actions selector to be fixed at the bottom of the page.
- 2c6a525: Fixes an invalid GCP Organization selector terraform example in the Access Selector playground.
- 820a2ef: Pass in the builtin provisioner webhook url to the Control Plane and Access Handler services.

## 2.6.0

### Minor Changes

- 6ea25f1: A reason is now required when using breakglass to activate an access request
- 6ea25f1: Create View for all access request statuses in My Access Requests Page.
- 6ea25f1: Admins can now delete users from the users list table
- 6ea25f1: Integrations now have their own detail page where config can be reviewed/edited and background tasks relating to integrations can be inspected

### Patch Changes

- 6ea25f1: Fixes an issue with GCP access de-provisioning where a request for multiple roles on the same target, such as a Project or Folder, could result in one of the roles not being removed when the request was closed.
- 6ea25f1: Added the AWS account number to the target field in Slack messages.
- 6ea25f1: Add additional validation to availability spec apis to make sure domain identities cannot be empty
- 6ea25f1: Fix issue causing large target and role names to be hard to read in the request detail table
- 6ea25f1: Route users without access to integrations in the settings to the notifications panel
- 6ea25f1: Fix issue causing duplicate roles to show in entitlement previews
- 6ea25f1: Fix an issue where the policy simulator would not match policies including 'resource.approved' constraints.

## 2.5.2

### Patch Changes

- 5aa2b10: Fixes an issue with GCP access de-provisioning where a request for multiple roles on the same target, such as a Project or Folder, could result in one of the roles not being removed when the request was closed.
- e86589a: Adds snapshot identifer and suffix for rds instance to enable creating rds instance from snapshot
- bc1e5f9: Makes target groups to ECS services configurable, allowing additional load balancers to be added to a Common Fate deployment.
- 5aa2b10: Fixes an issue where JIT requests to the Common Fate administrator role would not be correctly revoked.

## 2.5.1

### Patch Changes

- 17e8c01: Adds cedar action CF::Authz::PolicyService::Action::"DeletePolicySet" to allow the action to be forbidden except for the terraform service.
- 17e8c01: Fixed an issue which prevented bulk request actions working on the access request table due to a 404 not found error. Additionally fixed a styling issue with the force close prompt.
- 17e8c01: Fixes an issue where the edit integration feature flag would not be set to enabled despite the user having the admin role.
- 17e8c01: Fixes an issue where the ListIntegrations rpc was not marked as a read only operation in authz logs.
- 17e8c01: AWS IDC integration now only syncs active accounts.
- 17e8c01: Fixes an issue where JIT requests to the Common Fate administrator role would not be correctly revoked.

## 2.5.0

### Minor Changes

- 0f892af: Add user-configurable opt-in/opt-out settings for Slack DM notifications.
- 0f892af: Adds additional authorization log filtering capability to the API, the filter API now supports a boolean condition on entity filters and adds entity type filters.
- 0f892af: Adds a new page in the settings to view and debug Selectors. A selector playground is also added to test selectors in real time before deploying the selector.
- 0f892af: Adds a basic policy page to the Settings tab which allows for viewing and deleting access policies
- 0f892af: Integrations can now be configured and updated via ClickOps in the Common Fate Console.
- 0f892af: Adds an additional principal type filter to the authz eval page in the console. Logs can now be filtered by User or Service.
- 0f892af: A new page has been added showing the users own access requests, rather than all access requests. The request page has also been updated with a tab for pending, active and closed requests, making it easier to find what you are looking for.
- 0f892af: The AWS RDS Proxy integration has been overhauled to seperate database configuration from the proxy infrastructure. This change improves the reliability of the AWS proxy and makes it easier to configure where teams have databases deployed in different terraform stacks.

  This is a breaking change for the AWS RDS Proxy, teams using the previous version of the proxy will need to redeploy the proxy and add databases as seperate modules in terraform.

### Patch Changes

- 19fd33f: Add namespace and stage environment variables to the control plane
- 0f892af: Add help documentation for advanced search features on the new request page
- 0f892af: Adds the ability to filter all access requests by principal, approver, closer as well as by status pending, active and closed
- ba1c8db: Removes the hardcoded AWS provider block in the module. Fixes an issue where the module could not be destroyed due to the provider block being present.
- 0f892af: Fixes an issue where provisioning would fail for S3 bucket access when a provisioner webhook was configured in the config but not with the dynamic access capability.
- 2d753cd: Adds permission for the Control Plane to write parameters to SSM under the /{namespace}/{stage}/\* namespace
- 0f892af: Fix issue where S3 audit log export continually rewrites the last event.
- 0f892af: Adds permission checks to the integration page in the settings UI, this and other application configuration pages will only be viewable if the user has is an administrator or has a policy permitting the CF::Admin::Action::"Read" action.
- 0f892af: Adds syntax highlighting for cedar policies and json entities in the access debugger and authorization logs.
- 0f892af: Fix a concurrency issue which could lead to panics when loading entities

## 2.4.4

### Patch Changes

- f3f1c13: Fix issue where S3 audit log export continually rewrites the last event.

## 2.4.3

### Patch Changes

- d2c3801: Fixes an issue where email casing was not ignored in the connected identities sync which could result in duplicate users being created and identities not being linked correctly.
- d2c3801: Fix issue where both default duration and max duration error messages appear when duration is set to zero.
- d2c3801: Add grant_id and access_request_id to otel traces in provisioner.
- d2c3801: Fixes an issue where the access handler would skip deprovisioning RDS proxy access in cases where the proxy config had been changed while a grant was active. Now, regardless of the config changing, the access handler will always attempt to remove the Permission Set that was created to grant access.
- d2c3801: Fix an issue where a broken navigation link was shown in the user profile menu.

## 2.4.2

### Patch Changes

- f908555: Fix an issue where CloudWatch based alerting topics were not exposed as an output

## 2.4.1

### Patch Changes

- 42de9f4: Fixes an issue in the Worker task which could cause it to fail on the first deployment of version 2.4.0

## 2.4.0

### Minor Changes

- d3903e9: Adds a healthcheck to the centralised monitoring service which reports on service health.
- d3903e9: Adds the ability for the builtin Administrator role to fetch API Client secrets via the API
- d3903e9: Extensions are only allowed after 50% of duration had elapsed.
- 47e7747: Adds cloudwatch alarms for ALB, database and SQS
- ad678b7: Adds support for inviting an initial set of users to Common Fate when Cognito is used as the login provider. initial_user_emails is a comma seperated list of emails which will be created in Cognito and have an initial invite email sent.
- d3903e9: Adds tags and tag_keys attributes to AWS::IDC::PermissionSet resources which can be used to restrict access in Cedar policies
- d012909: Administrative users can now be added to the deployment, these users will be automatically assigned to the administrative role in Common Fate. On an initial deployment, they will also be invited to cognito.
- d3903e9: Built-in roles can now be requested using the JIT request workflow with access governed by cedar policies. For new deployments, an initial policy is created which permits access to the administrative role. In existing deployments, no default access is create, teams can add the cedar policy to expose this role if required.
- d3903e9: Add default Cedar policies which prevent users being able to request access to resources when they do not have the required linked identity.
- d3903e9: Adds built-in roles for managing Common Fate. Initially an Administrator role has been added which is permitted to access OIDC secrets and configure integrations.

### Patch Changes

- d3903e9: The Access::Action::"ForceClose" action will now only be evaluated if the force close option is provided in the API request. This change reduces excess policy authorization noise in the authorization log for authorization results that are never used.
- d3903e9: Improve observability of Pager Duty sync tasks and add an expiry window of 5 minutes to the PagerDuty token refresh process
- d012909: Add a validation check for the ALB certificate which waits for it to be issued.
- d3903e9: Fixes an issue where Target and Role options would not load for some Access Requests in Slack.
- dded0d1: Expose the API client secrets to the control plane for the administrative API
- 5e35d44: add environment variables for configuring factory monitoring
- d3903e9: Fixes an issue which prevented using BatchEnsure to activate an approved request when a duration was provided
- d3903e9: Fixed an issue causing creating access workflows to fail when extension conditions was not set
- d3903e9: Fixes an issue causing duration to not be shown on slack messages for access requests
- d3903e9: Improve the tracing on Ops Genie sync and update retry logic
- d3903e9: Adds deployment configuration page to the setting tab in the web console. Exposes configuration parameters required to configure a deployment. This page is only available to users assigned the CF::Admin::Action::"Read" action
- d3903e9: Prevent panic when calling DebugEntitlementsAccess due to concurrent map writes error
- d3903e9: Update open telemetry middleware to correctly capture panics
- d3903e9: The AWS resource sync task now correctly handles access denied errors when syncing tags for buckets fails

## 2.3.3

### Patch Changes

- e52bd84: The Access::Action::"ForceClose" action will now only be evaluated if the force close option is provided in the API request. This change reduces excess policy authorization noise in the authorization log for authorization results that are never used.
- e52bd84: Improve observability of Pager Duty sync tasks and add an expiry window of 5 minutes to the PagerDuty token refresh process
- 73e84c3: Add an output for the Application Load Balancer ARN.
- d6f3459: Fixes Role Name not showing in the new request checkout.
- e52bd84: Fixed an issue causing creating access workflows to fail when extension conditions was not set
- b22710a: For BYOC customers: the Okta Sync background task can now be disabled.
- e52bd84: Improve the tracing on Ops Genie sync and update retry logic
- e52bd84: Prevent panic when calling DebugEntitlementsAccess due to concurrent map writes error
- e52bd84: Update open telemetry middleware to correctly capture panics
- e52bd84: The AWS resource sync task now correctly handles access denied errors when syncing tags for buckets fails

## 2.3.1

### Patch Changes

- 75fd002: Fixes an issue preventing requests being made via the Console when the user is not permitted to use the GetResource API

## 2.3.0

### Minor Changes

- 9e38ba2: Add Common Fate styling to the cognito invite email
- c818f0d: Adds resource syncing support for AWS. Initially, our resource syncing implementation syncs S3 buckets.
- c818f0d: Adds Dynamic role provisioning for AWS S3 Buckets. Users may now request access to particular S3 Buckets in an account and have a single role provisioned with the requested level of access for each Bucket.
- c818f0d: Adds identity syncing for OpsGenie and Datastax
- 23891d3: Managed Monitoring for deployments is now enabled by default (https://docs.commonfate.io/setup/managed-monitoring).
- c818f0d: The Resources tab and APIs are now gated behind the action CF::Directory::Action::"GetResource" which is part of the CF::Admin::Action::"Read" action group. Users without these permissions will no longer be able to view this page.
- 85ff085: Added maintenance_mode_enabled and maintenance_mode_message variables to control the maintenance mode with customizable message.

### Patch Changes

- c818f0d: Improve concurrency when provisioning multiple grants on a request.
- c818f0d: Removes extend button from slack channel notifications
- c818f0d: The ID of each integration is now shown in the web console Integrations page.
- c818f0d: Fixes an issue with displaying error messages when setup fails for a Slack or PagerDuty integration
- c818f0d: Fixes an issue that would force a user to use breakglass to activate via the web console if both breakglass and regular activation were permitted actions.
- 3122209: Fix an issue where the Common Fate API would return a internal server error when trying to update a Slack Alert that no longer exists.
- c818f0d: Fixes an issue when updating the path of a secret from PagerDuty or Slack during setup, the complete setup URL would point to an integration ID which does not exist, requiring you to remove and recreate the resource in terraform.
- 3122209: fix issue causing extension conditions to always require updating in Terraform
- c818f0d: Fix AWS Account names not shown when they contained S3 buckets
- c818f0d: Fixes an issue which may cause the Okta identity sync task to fail due to mishandled pagination parameter
- c818f0d: For BYOC customers: adds OpenTelemetry instrumentation to database migrations.
- c818f0d: Prevents issues with PagerDuty sync failing due to Expired Token errors
- c818f0d: Add RDS icon for RDS Databases
- c818f0d: Nest RDS Databases under their AWS Account in the new request page
- c818f0d: Fix eventbridge errors when requesting more than 5 entitlements at a time
- 37f5b61: Pass the cognito SAML configuration through to the control plane service
- 3122209: Adds a background task to monitor for any differences in authorization ahead of a migration to Connected Identities for authorization descisions
- c818f0d: Fixes insights access hours calculation showing 0 hours reduced
- c818f0d: Fix an issue where Common Fate would report an internal server error is a workflow was deleted and Slack Alerts were still present
- c818f0d: Include OpenTelemetry trace ID in internal server errors
- 3122209: Improve tracing on Okta sync workflows

## 2.2.0

### Minor Changes

- 6a3d6d2: For BYOC customers: adds a configuration flag to enable/disable the pull-based Entra Identities Sync background task.
- be3fafa: Adds advanced search capability to the new request page including fuzzy search and logical conditions
- 01df860: Adds configuration variables for usage reporting.
- be3fafa: The Read-Only client is now permitted to preview user access. You can use this to develop automations that preview user access within Common Fate.
- be3fafa: Users and groups are now shown in a dedicated directory view in the Common Fate web console.
- be3fafa: Adds support for force closing Access Requests where deprovisioning has failed. To close these requests, give yourself permission to perform `Access::Action::"ForceClose"`. You will then have the ability in the web console to forcibly close Access Requests.
- be3fafa: Adds pull-based syncing for Microsoft Entra.
- be3fafa: Adds 'Department' attribute to users. This attribute is synced with the Okta 'department' attribute.
- c053d32: For BYOC customers: adds Terraform variables to configure the access and refresh token duration for the CLI client.
- be3fafa: Adds Open in Console button to slack messages
- be3fafa: Common Fate deployments now report usage (such as user and integration count) to the Common Fate deployment metadata service.

### Patch Changes

- be3fafa: Fixes an issue which would cause the new request page to lag when searching for an entitlement
- be3fafa: For BYOC customers: background task diagnostics metrics are now emitted as an OpenTelemetry trace.
- be3fafa: Fixes a typo in the Preview Access web console text.
- be3fafa: Populate the names from discovered accounts if name does not exist.
- be3fafa: Fix pagination handling for Entra ID sync task
- be3fafa: Make audit_message_type nullable.
- be3fafa: Fixes a latency issue when viewing Common Fate deployment insights.
- be3fafa: Correctly handle the case where a workflow is deleted before a grant in closed when returning the results in the Close API
- be3fafa: Fix an issue where Common Fate would report an Internal Server Error if a workflow was deleted while availabilities were still present.
- be3fafa: Fixes a caching issue when querying for available entitlements.
- be3fafa: Improve the efficiency of the Entra ID sync task
- be3fafa: Fix an issue where the web console would show an error 'override duration cannot be greater than max duration'.
- be3fafa: fix issue causing long policies to overflow in preview entitlement access
- be3fafa: Fix an issue where the AWS Organizational Unit icon would not be shown in light mode in the web console.
- be3fafa: Fixes issue causing increased latency in the web console.
- be3fafa: For BYOC customers: adds OpenTelemetry instrumentation to provisioning/deprovisioning calls.
- 78bbdf7: Exposes ecs_task_memory and ecs_task_cpu variables for the control plane, workder and access handler services.
- be3fafa: Adds principal ID to API otel tracing spans
- be3fafa: Fixes policy highlighting in the preview debugger when policies have annotations

## 2.1.0

### Minor Changes

- d7a212f: Users can now select the duration when using the Slack request workflow.
- d7a212f: Add support for extend access configuration with max extensions and extension duration in access workflows.
- d7a212f: Add stats page for access requests and privilege reduction
- d7a212f: Common Fate users are now proactively provisioned for our Slack, AWS IAM Identity Center, and PagerDuty integrations. Common Fate user accounts will be created automatically for user accounts in these integrations.

  This fixes an issue where users would have to wait for an initial integration resource sync before they could request access to entitlements.

- d7a212f: Deprecate TryExtendAfter in favour of ExtensionConditions.
- d7a212f: fix issue causing incorrect duration to be returned in batch ensure
- d7a212f: Slack integration messages now include information on who approved the request.
- d7a212f: The /access command now skips the resource type selector if only one access integration is installed.

### Patch Changes

- d7a212f: Fix the contrast on the menu options when hovering in the preview access page in the web app
- d7a212f: Don't show breakglass option for a request that is already approved
- d7a212f: Fix an issue preventing Entra users from being linked with Common Fate user accounts.
- d7a212f: Fix UI overlap on the breadcrumb component in the web app
- d7a212f: Add grpc message validation to API middleware
- d7a212f: Fix an issue where the 'Review Requests' panel would be shown when the web console was opened.
- d7a212f: fix action button in request list for smaller screen widths
- d7a212f: Entra SCIM integration now correctly handles the case where a group is a member of another group.
  Previously all members of groups were treated as users, which meant that nested groups could not be used in access policies correctly.
- d7a212f: Okta Integration config is now validated on updates from terraform.
- d7a212f: fix issue causing principal to be incorrect on created grants
- d7a212f: Fixes an issue which would prevent a grant from being closed if the availability spec was removed while the grant was pending or active
- d7a212f: Add the grant principal to audit logs for grant actions
- d7a212f: Don't show the approve button on slack channel messages for requests which were auto approved or breakglass activated.
- d7a212f: update slack messenger to send push notification updates for important request lifecycle changes
- d7a212f: Improve the contrast of the authorization graph in light mode

## 2.0.3

### Patch Changes

- b707d12: Fix an issue where Terraform would reset the 'schema' attribute on the Cognito user pool for some deployments.

## 2.0.2

### Patch Changes

- 24b26c8: Fixes an issue in the Service Connect configuration which was causing a 15 second timeout. This would cause access requests to fail in some instances when multiple entitlements were requested.

## 2.0.1

### Patch Changes

- f503835: Fix an issue preventing Entra users from being linked with Common Fate user accounts.
- f503835: Fix an issue where the 'Review Requests' panel would be shown when the web console was opened.
- f503835: Add the grant principal to audit logs for grant actions

## 2.0.0

### Major Changes

- 5beef23: For BYOC customers: Removes the Authz service, which has been fully deprecated as of application version 4.3.0.
  The supporting DynamoDB table for this service will remain until a future release when it will be removed.
  The CloudWatch log group for the Authz service will remain until a future release when it will be removed.
- e56d0bd: For BYOC Customers: Removes team_name and logo_url variables and support for customising the appearance of the web app.
- e56d0bd: For BYOC Customers: This change removes the PagerDuty and Slack configuration from the infrastructure stack. These integrations are now entirely configured in the application config.
- e56d0bd: For BYOC Customers: This change removes the provisioner config variables from the infrastructure stack. To upgrade, you will need to remove any references to these variables in your config. The provisioner is now configured entirely from the application configuration.
- e56d0bd: For BYOC Customers: This change removes unstable_enable_feature_least_privilege, unstable_sync_idc_cloudtrail_schedule and unstable_least_privilege_analysis_schedule variables as this feature has been removed from the application.

### Minor Changes

- e74c376: Send slack notification to notify users at a preset time before their access expires.
- 96af06e: Add Otel container definition to provisioner module
- e74c376: Adds ability to prioritise roles when creating availabilities. The highest priority role will be suggested in the entitlement request UI
- e74c376: Adds new recently used section to entitlement select tree which displays 3 most frecently used entitlements
- e74c376: Add event filtering to webhook integration
- e74c376: Notify slack approvers and channel when breakglass access is used
- e74c376: Adds support for breakglass access, when enabled, users who have permission will be able to skip approvals for specific entitlements.

### Patch Changes

- 6b3dc4d: Update slack expiry notification to include target and role which are expiring.
- e74c376: Fix "Open Console" showing on requests for other users in the requests list view.
- e74c376: Adds OTEL tracing to the Provisioner and improves the tracing for the Control Plane http APIs
- e74c376: Fix logic for creating profiles based on an entitlement requested with batch ensure
- d58a647: Fixes a permissions issue which prevented the provisioner from reading secrets from SSM Parameter store at runtime, for integrations such as Okta, Entra, Auth0
- 9c05918: Fixes a cyclic reference issue when the ALB certificate ARN depends on the output of another Terraform module.
- e74c376: Add tracing to the Provisoner and emit traces to AWS X-Ray
- e74c376: Fixes an issue causing the activate button not to be shown on Slack DMs when the approval policy checks for a principal condition.
- e74c376: Further improvements and fixes to new hierarchy UI to improve search and readability
- 6b3dc4d: Fix an issue where the Access Request confirmation accordion would not open by default in the web console.
- e74c376: Fix scrollbar always showing on requests list view
- f3ccd4b: Adds centralised monitoring environment variables to the provisioner module

## 1.45.1

### Patch Changes

- 991a6aa: Fix an issue causing the activate action not to show in slack DMs

## 1.45.0

### Minor Changes

- a7b84d7: Provisioner no longer depends on infrastructure configuration for integrations.
  Teams using AWS or GCP integrations are required to follow the migration guide prior to updating to this release.
  https://docs.commonfate.io/migration-guide/migration-guide#v1-45-0
- a7b84d7: For BYOC customers: the `authz` service is no longer used. We plan to remove it in a future release.
- 57f05c2: deprecate configuring the provisioner via the infrastructure config
- a7b84d7: New access page for requesting target and role combinations laid out in a tree format

### Patch Changes

- a7b84d7: Fixes an issue that could lead to a denial of service with the policy API if a malformed or forbid all policy was created. The CF::Service::"Terraform" which is service principal assumed by the terraform client credentials is now always permitted to use the policy APIs regardless of the customer policies applied, preventing customers from being unable to revert a bad policy change.
- a7b84d7: Fix active requests in the requests list not opening the request detail page when clicked
- 5b53143: Update default idle timeout on the ALB to 2m 30s to accomodate for the retry timeouts in the provisioners
- 64073c2: Fix AWS IAM Identity Center Linked Identity cleanup.
- 64073c2: Skip attempting deprovisioning if requested resources no longer exist.
- a7b84d7: Fix an issue causing SCIM Group APIs to fail on update operations.
- a7b84d7: improve action button to give more information on what button does
- a7b84d7: Slack integration will now only show activate button if the user viewing the notification has permissions to activate the grant
- a7b84d7: Refresh audit logs on request detail page every 10 seconds.

## 1.44.0

### Minor Changes

- a361487: Removes the requirement to configure pager_duty_client_id, pager_duty_client_secret_ps_arn, slack_client_id, slack_client_secret_ps_arn, slack_signing_secret_ps_arn variables in the infrastructure layer. This configuration is now pulled directly from the integration config resources in your application configuration.
- 1cf453f: Removes the 'cf authz policyset validate' server-side validation command in favor of client-side validation.
- 1cf453f: Remove the requirement for Slack, PagerDuty and OpsGenie to be configured in the infrastructure layer. Config is now read from the integration resources in terraform.
- 1cf453f: Support requiring all request actions to be forced to use the CF console.
- 1cf453f: Implement security headers and conceal server tokens in Nginx.

### Patch Changes

- 1cf453f: Fix api pagination sometimes returning duplicate results
- 1cf453f: Fix an issue where old Access::LinkedIdentity entities would not be cleared when an AWS IDC User is removed.
- 1cf453f: Fix an issue where the default duration information would flicker in the web console.
- 1cf453f: Fixes an issue causing slack alerts not to be sent to channels when a request is created
- 1cf453f: Fix a nil pointer error sometimes observed when listing access requests
- 1cf453f: Add CF::Principal to resource page to improve debugging
- 1cf453f: Fix a login issue affecting some users
- fbd193a: Fix cloudwatch resource policy conditions not permitting events to be written to cloudwatch log group.
- 1cf453f: Fixes an issue where the migration of users from Authz to the internal postgres database resulted in both names being set to the firstname.
- 1cf453f: Fixes an issue where CF::User would show up in the resources view twice
- 1cf453f: Fixes an issue where a new user created in v1.42.0..2 may have been created with an incorrect ID
- 1cf453f: Support additional provisioner configuration fields on AWS and GCP integrations
- 1cf453f: Fix policy migration issue seen in v4.0.1..4
- 1cf453f: Fix an issue where the `sso_access_portal_url` field would not be used for AWS console links in the web console.
- 1cf453f: Fixes an issue where errors during first time login may not be caught

## 1.43.5

### Patch Changes

- ecf3053: Fix policy migration issue seen in v4.0.1..4

## 1.43.4

### Patch Changes

- 9913154: Fix a login issue affecting some users

## 1.43.3

### Patch Changes

- cb76ab3: Fixes an issue where the migration of users from Authz to the internal postgres database resulted in both names being set to the firstname in some cases.
- cb76ab3: Fixes an issue where a new user created in v1.42.0..2 may have been created with an incorrect ID

## 1.43.2

### Patch Changes

- 62cf20f: Fix api pagination sometimes returning duplicate results
- 62cf20f: Fix an issue where the default duration information would flicker in the web console.
- 62cf20f: Fixes an issue causing slack alerts not to be sent to channels when a request is created
- 62cf20f: Fix a nil pointer error sometimes observed when listing access requests
- 62cf20f: Add CF::Principal to resource page to improve debugging
- 62cf20f: Fixes an issue where CF::User would show up in the resources view twice
- 62cf20f: Fixes an issue where errors during first time login may not be caught

## 1.43.1

### Patch Changes

- 9d2885e: Fix an issue where the S3 Audit Log Destination write role used a confusing tag. The role can now be tagged with 'common-fate-allow-assume-role=true' to allow Common Fate to assume it.

## 1.43.0

### Minor Changes

- eedee50: Update bundled application version to v4.0.0

  Major Changes
  6505c33: For BYOC customers, removes the dependency on the authz service and the underlying DynamoDB table for all APIs. API performance is improved and overal running costs are reduced.
  Minor Changes
  95d2486: Adds deep linking to the AWS console. After requesting access to an entitlement, clicking the 'open URL' button will open the AWS console with the requested account and role.
  2ec349f: You can now select multiple Access Requests in the web console to approve or close all of them at once.
  Patch Changes
  69e8eb4: Use default duration instead of max duration for grant expiry when no duration is supplied in the request.
  49340a6: Fix an issue where the Auth0 integration icon was not correctly displayed in the web console settings page.
  eef2f72: Fix an issue where account name whitespace was not properly removed when using Common Fate as a Granted Profile Registry backend.
  21c710b: Adds CF::Service::"ReadOnly" with permissions to access the Schema and Policy APIs
  9b9f64a: For BYOC customers: fixes the formatting of the error log when duplicate users are found.
  2da33aa: Sets the name on Datastax users to their email.
  32e6ca4: Adds the ability to customise the AWS IAM Identity Center start URL used with the built-in AWS Profile Registry. To customise this, specify the sso_access_portal_url variable in the commonfate_aws_idc_integration resource.
  608cb10: Fix an issue where Auth0 access tokens were not refreshed.
  6505c33: Fix Debugger UI not showing a user if their name is not set.
  33973eb: Remove access grants, access requests and audit logs from the resources API.
  ae50f5c: Disable approve button if approve action is not available to the user.
  93b2fec: Add Access Request justification to webhook events

- 9d30b41: Removes the networking configuration for the Graphql API which has been removed from the authz service.

### Patch Changes

- c68d1be: Add service account OIDC client IDs to control plane environment
- 90a6f83: Add Read only client to cognito
- fc0b4ec: Redirect policyset API to control plane

## 1.42.3

### Patch Changes

- 7df0e6f: Patch Changes
  f81192d: Fix background data migration for users.
- a64ebb6: Adds given name and family name SAML attributes to client

## 1.42.2

### Patch Changes

- 00085cf: Fix an issue where account name whitespace was not properly removed when using Common Fate as a Granted Profile Registry backend.
- 00085cf: Fix an issue preventing Grants from being migrated to the new Common Fate internal storage backend.

## 1.42.1

### Patch Changes

- af5ede5: Patch Changes
  819fdc5: Adjust overflow width of resource detail attributes.
  446392e: Fix an issue which prevented centralised_support from being disabled due to browser caching.
  1c3ec55: Prevents some internal errors being exposed in diagnostics from the Access Handler APIs.
  1c3ec55: Improve handling of Principals data migration during deployment upgrades.

## 1.42.0

### Minor Changes

- fdde12e: @common-fate/terraform-aws-common-fate-deployment@3.13.0
  Minor Changes
  03bdf87: For BYOC customers: adds OpenTelemetry instrumentation of write operations to DynamoDB.
  bdc4db3: Adds support for requiring a reason on Access Requests.
  cd49fa1: Added ListProfiles api to be used with Granted for filling ~/.aws/config with Common Fate profiles
  85a21e6: Added support for setting default durations on Access Workflows.
  Patch Changes
  0512476: Centralised support can now be disabled by setting a variable in CF Terraform deployment module
  9477ed6: Fix entity not found errors for Grant types on the Authorization Log page in the web app.
  47c6a7b: Fix to Slack interactivity causing 500 errors when activating or closing requests
  46781fd: Fixes an issue where users could not access AWS immediately after logging in for the first time.
  5502339: Fixes an issue causing Auth0 resource syncing to fail due to a permissions error.
  8c154d5: Fix an issue where user names were not shown in the web console Access Request list.
  b4dd0d0: For BYOC customers: reduces the severity on the error-level log if deprovisioning is skipped to be info-level.
  fd55c30: Improve configuration API integrity and performance
  3679361: Improve the robustness of database migrations. Common Fate can now handle deployment rollbacks where migrations have been run.
  f1a6ee8: Fix an issue which could cause active grants to be revoked if the activation expiry is exceeded.
  bcc3240: Format durations and timestamps in resource view to be human readable.
  8bf869d: Add the environment variable CF_FORCE_CONFIG_MIGRATIONS to enable forced migration of configurations for optional fields.
  7a06805: Set the Default Duration to the Access Duration if not initially configured.
  bbbdaaf: For BYOC customers: allow disabling automatic database migrations when the Control Plane container starts.

## 1.41.2

### Patch Changes

- 345c247: Fix to Slack interactivity causing 500 errors when activating or closing requests
- 6331b4f: Add option to force rerunning the configuration migration on startup.

## 1.41.1

### Patch Changes

- 4ccb495: Allow disabling automatic database migrations using the `database_auto_migrate` variable when the Control Plane container starts.
- 8014185: Fix an issue which could cause active grants to be revoked if the activation expiry is exceeded.
- 8014185: For BYOC customers: allow disabling automatic database migrations when the Control Plane container starts.

## 1.41.0

### Minor Changes

- c84bcf8: Adds provisioning configuration for the Common Fate Auth0 integration.
- 3a7c2be: Adds support for requesting access to a GCP Role Group. A Role Group is a group of multiple roles which are requested and assigned together. GCP Role Groups allow you to work around the permission count restriction in custom roles.
- 3a7c2be: Adds Auth0 integration.
- 3a7c2be: Updates API for slack alerts to allow for configuring messages via direct message to approvers
- 55e6057: Adds VPC Endpoints for services used in the stack.

### Patch Changes

- 3a7c2be: For BYOC customers: fixes an issue where the 'version' attribute on OpenTelemetry spans was not being set.
- 3a7c2be: Fixes name based lookups for target and role when using the CLI to ensure access when the embedded authorization feature flag is enabled.
- 3a7c2be: Fix an issue where auto-approved access would use a lower priority Access Workflow, if the Access Workflow had a longer duration.
- 3a7c2be: Improve performance of the integration APIs
- 3a7c2be: Fix an issue causing the duration input to reset when requesting access in the web console.
- 3a7c2be: Fixes an issue where invalid configuration could cause the built-in Provisioner to report 'no provisioner has the capability to Grant <Role> on <Target>'. If you have a single provisioner registered with your Common Fate deployment, we'll always try and call it rather than reporting an error if the capabilities aren't correctly configured.
- 3a7c2be: Performance improvement for the Availability Maker background process.
- c51b5d8: Enable embedded authorization by default
- 3a7c2be: Fix an issue on the new request page which would cause the access duration to reset when the reason was updated.

## 1.40.2

### Patch Changes

- e2a931b: For BYOC customers: fixes an issue where the 'version' attribute on OpenTelemetry spans was not being set.
- e2a931b: Fix an issue where auto-approved access would use a lower priority Access Workflow, if the Access Workflow had a longer duration.
- e2a931b: Fix an issue where containers could fail to start if the Common Fate support API was unable to issue an access token to the deployment.

## 1.40.1

### Patch Changes

- 4d7de64: Fix an issue causing the duration input to reset when requesting access in the web console.
- 4d7de64: Fix an issue on the new request page which would cause the access duration to reset when the reason was updated.

## 1.40.0

### Minor Changes

- 1ee7409: Adds a dead-letter queue to the event handler SQS queue.
- 1ee7409: Adds support for Managed Monitoring. When enabled, a Common Fate deployment will emit OpenTelemetry events to our centralised OpenTelemetry collector, allowing the Common Fate team to diagnose performance issues and proactively detect errors in your deployment. No identifiable information is included in the OpenTelemetry events.

### Patch Changes

- 58b9370: Updates the built-in application version to v3.11.0 , including the following changes:

  Minor Changes
  5f64825: Adds additional OpenTelemetry attributes to authorization events.
  2f1b875: Improves the performance of API authorization.
  2a60d42: Workflows can now be configured with an activation expiry deadline to automatically close requests that have not been activated for a set period of time after being approved.
  5d659e1: Adds support for Managed Monitoring. When enabled, OpenTelemetry traces are dispatched to Common Fate's centralised monitoring infrastructure to allow our team to proactively monitor your deployment. No identifiable information such as email addresses or cloud resource metadata is included in any monitoring events.

  Patch Changes
  d67388a: For BYOC customers: fixes an issue where event handler logs were noisy. Info-level logs have been shifted to Debug.
  0831fdd: For BYOC customers: fixes an issue where error logs would be emitted during container shutdown.
  b913687: Improve query performance for integration entities by using a more performant encoding strategy for attributes.
  8e942aa: For BYOC customers: fixes OpenTelemetry API errors being included in spans with "An unexpected error has occured."
  ff0b8d3: For BYOC customers: logs emitted when identities are not matched have been reduced to 'info' level rather than 'warn'.
  3ffd115: For BYOC Customers: the Access Handler now connects to the Common Fate RDS database.
  e13d669: Shows 'Approvers' as a column title in the Access Request detail table header.
  8754da8: The web console now shows the Access Workflow name associated with a particular Access Request, when viewing the Access Request details.
  ebc1d4c: Fix missing mapping of ListBackgroundJobKindSummary to Admin::Action::"Read" action.
  45e1db0: Introduces improved authorization performance, available as an opt-in feature flag.
  cfd0187: Adds Parents tab to the resource detail view in the web UI.

- cad9494: Enable the Access Handler service to connect to the RDS database.
- a9cc4ab: Add unstable feature flag for embedded authorization
- b835a74: Grant permissions for the control plane and access handler services to write to the authz eval bucket.

## 1.39.0

### Minor Changes

- cc8a9b1: When viewing an Access Request which needs approval, you'll now see a list of users who are authorized to approve access.
- cc8a9b1: Adds Access Preview. Common Fate administrators can now list the entitlements that end-users can have authorization to access. Access Preview shows whether access will be auto-approved, and indicates the particular authorization policies which contribute to the authorization decision.
- 12acbd7: Adds variable to allow for Multi-AZ on RDS database.
- e43324c: The Common Fate web console now filters entitlements by default. If an end-user doesn't have authorization to request access to an entitlement, it will not be shown in the list to select from in the web console.
- fe1c946: Adds 'rds_apply_immediately' variable to immediately apply RDS changes. Set to 'true' by default.

### Patch Changes

- e59ab5d: Removes `unstable_enable_feature_access_simulation` variable from the Terraform module. This was used during the preview period for the Access Preview feature.

## 1.38.0

### Minor Changes

- f8498b0: GCP Integration Module: adds optional support for provisioning access to GCP organizations and GCP BigQuery resources, which require additional IAM permissions.
- 96ca1d3: Common Fate now supports webhook integrations. You can use webhook integrations to route events to other security tools, or use them to build your own notification integrations.
- 96ca1d3: Adds support for Just-In-Time access to GCP BigQuery Tables.
- 96ca1d3: Adds an in-app contact form which can be used to reach Common Fate support if you have questions, feedback, or problems.
- 96ca1d3: The retention for authorization events (visible in the "Authorization" page in the web console) is now 1 year by default. After the retention period, events will be removed from the Common Fate database. For BYOC customers, events will still be present in CloudWatch, depending on the retention period you have configured for your log group.
- 96ca1d3: Adds support for Just-In-Time access to GCP BigQuery Datasets.
- 96ca1d3: Adds an entitlement access debugger which provides detailed information about the policies and entities which are affecting a users ability to request access to an entitlement and whether they require approval.
- cfed93f: Adds SNS topic for alerting on Common Fate background job failures.
- cfed93f: Adds SNS topic for alerting on ECS deployment failures.
- 96ca1d3: For BYOC customers: Common Fate now emits `job.failed` event when a background job fails, and a `job.completed` events when a background job completes successfully.
- 96ca1d3: Adds support for obtaining an AWS profile (to be stored in `~/.aws/config`) for a particular AWS account and role when using the Common Fate CLI.
- cfed93f: Enables ECS Circuit Breaker for ECS services.
- 96ca1d3: Add support for Just-In-Time access to GCP Organizations, by granting an organization-level role.

### Patch Changes

- 96ca1d3: Fix error handling for slack integrations in the event handler. In some cases a database error would be reported as having no integrations configured.
- b3cf16e: Redirect the DebugEntitlementAccess RPC to the control plane
- 0321530: For BYOC customers: the Common Fate Control plane now serves the Granted Profile Registry API. We've updated the load balancer rules to reflect this.
- 96ca1d3: Fixes an issue where the Common Fate could not reconnect to the database after a password rotation.
- 96ca1d3: Fixes an issue where some access preview APIs would not return the expected results for particular policy types.
- 7acb3f3: Permit the control plane and worker task role to fetch the database secret from secrets manager. This change is implemented to support application layer database credential rotation support.

## 1.37.0

### Minor Changes

- c602cf6: Adds variables which allow for point-in-time restore for DynamoDB

### Patch Changes

- c540522: Fixes an issue which prevented the 'Approve' button from showing in the web console.

## 1.36.0

### Minor Changes

- 38c997c: Redirect access service preview APIs to the control plane. Supporting change for application version v3.8.0+

### Patch Changes

- ed063ef: Updates the built-in application version to v3.8.1, including the following changes:

  Patch Changes
  271ec76: Mitigates an issue where duplicate user identifiers may be created when a user first signs in to the web console.
  d202dc5: Fix an issue where DataStax Organization Grant entities could not be found.
  6026d2c: Fix an issue where available entitlements could be orphaned during integration resource syncing.
  321de36: Fixes an issue where AWS RDS Instance to AWS Account edges would be removed during aws idc sync.
  e3c139b: Users who are trying to approve access in Slack but have not yet signed in to Common Fate will now receive a more helpful error message.
  2b8c2b1: Revert a breaking change to the json serialisation of eids in the SDK.
  fda399c: Update background task runner to improve reliability and resilience to restarts while sync tasks are running. In some instances, tasks could be delayed from retrying for up to 2 hours after a restart.

  Minor Changes
  ae0d51b: A significant performance improvement to authorization.

  Common Fate now stores integration data (such as AWS accounts, PagerDuty teams, and GCP projects) in the Control Plane database. Access Preview and List Entitlements APIs now use this data source, and are now served by the Control Plane service. The access preview and query entitlements apis have been updated to pull their data from the control plane. This brings a significant performance improvement. The authorization service remains unchanged.

## 1.35.2

### Patch Changes

- afad394: Updates the built-in application version to v3.7.3, including the following changes:

  Patch Changes
  8323c0b: Fixes an issue where AWS RDS Instance to AWS Account edges would be removed during aws idc sync.
  f42dcd7: Revert a breaking change to the json serialisation of eids in the SDK.

## 1.35.1

### Patch Changes

- 733be7c: Fix an issue where DataStax Organization Grant entities could not be found.

## 1.35.0

### Minor Changes

- 6b1ad3d: Point-In-Time-Recovery (PITR) is now enabled by default for the Common Fate RDS database. Adds variables to restore from a PITR backup.

### Patch Changes

- 0059931: Mitigates an issue where duplicate user identifiers may be created when a user first signs in to the web console.
- 5caf1e1: Fix an issue where the `namespace`, `stage`, and `log_retention_in_days` variables were not propagated to the `ecs_base` module.
- 0059931: Fix an issue where available entitlements could be orphaned during integration resource syncing.

## 1.34.1

### Patch Changes

- 36b0147: Updates the built-in application version to v3.7.0, including the following changes:

  Minor Changes

  34ac234: The Common Fate Control Plane now additionally writes integration data (such as AWS accounts, PagerDuty teams, and GCP projects) to it's internal database. This is an internal change to make way for some planned authorization performance improvements.

## 1.34.0

### Minor Changes

- 64591cf: Adds support for syncing BigQuery resources (`GCP::BigQuery::Dataset` and `GCP::BigQuery::Table`)
- 64591cf: adds api for listing overview of all background tasks enabled and their current status

### Patch Changes

- 64591cf: Fall back to displaying the role ID if the role name is not present in the web console New Access page.
- 64591cf: Fix an issue where duplicate user emails would cause syncing workflows to fail.
- 64591cf: Security fix: by default, the GraphQL resource API will no longer return syntax suggestions by default.

## 1.33.0

### Minor Changes

- 1ad8a3d: Common Fate services now use internal hostnames to communicate with one another.

## 1.32.0

### Minor Changes

- 5de157a: Updates the built-in application version to v3.5.0, including the following changes:

  Minor Changes

  82f777b: Adds Preview User Access and Preview Entitlement Access (in beta) screens to the web app

  5466d82: Adds Experimental APIS for PreviewUserAccess: list the entitlements a user can request and whether they need approval PreviewEntitlementAccess: list the users who can request access and whether they require approval QueryApprovers: list the approvers for an entitlement or a specific grant QueryEntitlements: Modified to use a cache and return whether the entitlement would be auto approved

  Patch Changes

  79e7e6e: Reduces max attempts for all background jobs by default to 5 which equates to a maximum interval time of ~4m20s between the 4th and 5th attempt. Previously, we used the default 25 retries which would leave tasks failing for potentially 3 weeks at most and they needed to be cancelled manually once the issue was resolved. Because our background tasks are mostly cron jobs that fetch data, it is desirable for the jobs not wait longer than the standard cron interval before retrying.

  48b2449: Pager duty sync workflow will now skip syncing instead of returning an error when the integration is not yet configured.

  ae4667b: Add an indicator for the requester in audit logs. Adds a fallback to show the email if the users name is empty.

  c43824f: Fix an issue where the Access::Action::"Close" action was not applicable to the CF::Service entity type in the Cedar schema.

  1a39150: Add support for configuring Slack channel message approve actions to open the request in the web app for review.

  1640bbe: Adds a filter menu on the Access Request table for in progress requests. You can now filter by pending, active, requested, all.

## 1.31.1

### Patch Changes

- e9fa2fd: Updates the built-in application version to v3.5.0, including the following changes:

  Minor Changes
  82f777b: Adds Preview User Access and Preview Entitlement Access (in beta) screens to the web app
  5466d82: Adds Experimental APIS for PreviewUserAccess: list the entitlements a user can request and whether they need approval PreviewEntitlementAccess: list the users who can request access and whether they require approval QueryApprovers: list the approvers for an entitlement or a specific grant QueryEntitlements: Modified to use a cache and return whether the entitlement would be auto approved
  Patch Changes
  79e7e6e: Reduces max attempts for all background jobs by default to 5 which equates to a maximum interval time of ~4m20s between the 4th and 5th attempt. Previously, we used the default 25 retries which would leave tasks failing for potentially 3 weeks at most and they needed to be cancelled manually once the issue was resolved. Because our background tasks are mostly cron jobs that fetch data, it is desirable for the jobs not wait longer than the standard cron interval before retrying.
  48b2449: Pager duty sync workflow will now skip syncing instead of returning an error when the integration is not yet configured.
  ae4667b: Add an indicator for the requester in audit logs. Adds a fallback to show the email if the users name is empty.
  c43824f: Fix an issue where the Access::Action::"Close" action was not applicable to the CF::Service entity type in the Cedar schema.
  1a39150: Add support for configuring Slack channel message approve actions to open the request in the web app for review.
  1640bbe: Adds a filter menu on the Access Request table for in progress requests. You can now filter by pending, active, requested, all.

## 1.31.0

### Minor Changes

- e55113a: Adds a `unstable_enable_feature_access_simulation` variable to enable Access Simulation (a new feature, currently in beta)

### Patch Changes

- b914db0: Updates the built-in application version to v3.4.5, including the following changes:

  ### Patch changes

  cf4ba3c: Fix an issue where the Access::Action::"Close" action was not applicable to the CF::Service entity type in the Cedar schema.

## 1.30.0

### Minor Changes

- 2a832ec: Updates the bundled application version to be v3.4.4, including the following changes:

  ### Patch changes

  6f3ffbf: Fixes an issue where Cedar policy validation would return a warning for entity identifiers including a '/' character.

  a4210c7: Fixes an issue with the Cedar schema where an "Action" suffix was used in some namespaces.

  For example, CF::Control::Integration::Reset::ResetService::Action::Action::"GetOAuthTokenMetadata" is now fixed to be CF::Control::Integration::Reset::ResetService::Action::"GetOAuthTokenMetadata".

  a4210c7: Fixes an issue with the Common Fate Cedar schema, where the PagerDuty::User entity type was not a member of the PagerDuty::OnCall entity.

  ae20f85: Fixes an issue where Access Request validation would cause the 'Reason' field to freeze in the web console.

  6f8ede2: Fixes the formatting of advice in the permission denied message

  6f3ffbf: Updates the included Cedar version to be v3.1.2. This is a minor update and there are no breaking changes to Cedar policies.

## 1.29.0

### Minor Changes

- 7fdf501: Updates the bundled application version to be v3.4.3, including the following changes:

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

## 1.28.2

### Patch Changes

- c691f42: Patch Changes
  when updating a workflow in config a worker task will be run to update availabilities based onff any changes made to the workflow
  Fixes an issue which would cause Entra Users synced by scim not to be correctly related to CF::Users leading to policies not working as expected.
  for BYOC customers: improves logging in aws IAM Identity Center sync workflow

## 1.28.1

### Patch Changes

- de501fb: Minor UI improvements for the resources detail view page.

## 1.28.0

### Minor Changes

- 6bdfc2b: Minor Changes
  We've made a small change to Cedar authorization in preparation for releasing Cedar policy analysis tooling. The Cedar resource used for authorizing the Access::Action::"Request" action is now the Access::Availability entity, rather than the Access::Grant entity. This is a non-breaking change and existing Cedar policies will continue to behave identically.
  Patch Changes
  Fix issue causing multiple availabilities to be shown in the availability query
  web app will now display any diagnostic information on the grants from the preflight request in the overview page
  Adds the application version to the settings page in the web app.
  Add empty state to pending access requests table.
  Add empty state for resources pages in the web app.
  Reduce the verbosity of error messages emitted by the graphql API and correctly assign error codes.
  Adds the release tag for the application into the loggers for the services.
  Move cleanup workflow into using river queues

## 1.27.0

### Minor Changes

- deb75fa: Adds support for configuring the web console refresh token validity, using the 'web_refresh_token_validity_duration' and 'web_refresh_token_validity_units' variables.

### Patch Changes

- 57eb90e: Adds additional 'Condition' keys to the IAM roles used by ECS to protect against confused deputy issues.
- efccdca: The AWS RDS instance is now encrypted by default for new Common Fate deployments.
- 132f8ab: Adds release tag environment variable to the control plane and access services.

## 1.26.0

### Minor Changes

- 0db0cc8: Allows the Docker image repositories to be overridden using Terraform variables.

### Patch Changes

- 0db0cc8: Updates the default Docker image repositories to use ECR Public repositories rather than DockerHub. This mitigates rate limiting issues observed with the DockerHub repositories. Our ECR Public repository namespace is `public.ecr.aws/z2x0a3a1/common-fate-deployment`.

## 1.25.0

### Minor Changes

- 031b93b: Updates the bundled Common Fate application version to v3.3.2, including the following changes:

  - Minor Changes

    - Adds a log viewer and debugger for authorization evaluations

  - Patch Changes
    - (For BYOC deployments) fixes a formatting issue in the error log emitted in the event a Common Fate worker cannot reach the database.
    - The Access Request list is now shown at the /access/requests URL, rather than /access. The /access URL will automatically redirect you to the correct page.
    - Browser tab titles in the web console show a descriptive name based on the current page you're viewing.
    - Fix an issue where Common Fate background tasks could stop running when database credentials were automatically rotated
    - Fix an issue preventing the "Closed" Access Requests tab from opening in the Common Fate web console.
    - Fixes a typo in the comments on the Common Fate API Cedar policy.

### Patch Changes

- 82ee0c4: Adds configuration for authorization evaluation storage, including a new S3 bucket to store authorization evaluation data in.

## 1.24.1

### Patch Changes

- 60b1cd9: Use the correct cloudwatch log group for the Worker service

## 1.24.0

### Minor Changes

- ef2bf8f: Minor Changes
  Adds support for reducing the duration of access when making an Access Request.
  Patch Changes
  Matching user accounts in integrations via email address is now case-insensitive.
  Slack DM is always sent for requests which originate from Slack, improving the user experience.
  Improve the readability of the target selector list when making an access request via the web console.
  Adds an icon for the Okta integration in the settings page.
  Fix an issue where querying for grant output data (used in the Common Fate AWS RDS integration) would return an empty result
  Fixes an issue which caused the Common Fate Audit Log API to return some logs in non-deterministic order when they are created with the same timestamp. Logs now have an additional 'index' field which tracks the order they are created.
  Identity syncing workflows will now use the key "detail" instead of "error" in warning logs when a user from an external integration cannot be linked to an internal CF::User. This change reduces noise when filtering logs for errors.
  Security fix: GraphQL API introspection is now disabled by default.
- 5618d75: Add a slack cognito client to enable delegated slack based access requests to be attributed correctly to Slack as an origin

## 1.23.1

### Patch Changes

- a2aa9d0: Fixed incorrect default values for cloudtrail sync feature which would cause the Worker task to panic

## 1.23.0

### Minor Changes

- 733ce45: Adds `use_internal_load_balancer` variable, which can be used to make the Common Fate load balancer internal.
- 733ce45: Adds support for top-level BYOVPC variables, making it easier to deploy Common Fate into an existing AWS VPC.

## 1.22.0

### Minor Changes

- c0c341d: Minor Changes
  51db74c: Adds the ability to add multiple slack clients for different slack tenancies. As well as sending slack messages to different channels
  7329afa: Updates the SCIM implementation to fix an issue which would cause users to be created with their first name repeated.
  Adds support for resetting the Entra users which were created via SCIM, so that they can be reset in the event that the SCIM configuration was incorrect.
  5c7014b: Adds additional metadata to authorization evaluations, including authorization duration.
  Patch Changes
  cd3d1e4: Improve the target field of slack messages by including the target tye
  aaf54f7: Fix an infinite rerender bug on the resources pages that could be triggered by using the breadcrumb navigation
  cd3d1e4: Fix an issue which caused auto approved requests to have approval buttons in slack channel messages
  cd3d1e4: Fix an issue where activating a request from the CLI would not update the slack DM
  51db74c: When a slack integration is removed from terraform it will be uninstalled from the slack workspace and tokens will be removed.
  f511e30: Use a background task to update availabilities on demand when selectors or availability specs are updated in terraform configuration. Ensuring access is made unavailable shortly after the update.

### Patch Changes

- 0d92cca: Reduces the web app access token validity to 10 minutes by default.

## 1.21.0

### Minor Changes

- 89f9d84: Add an additional worker container to the controlplane task which runs background tasks.
- 0d3831d: Update the bundled Common Fate application release to be v3.0.0

  ### Major Changes

  e128940: Splits background workflows out into database backed work queue.

  ### Minor Changes

  d1e6cf7: Adds deployment diagnostics. You can fetch diagnostic information about your Common Fate deployment by running the `cf deployment diagnostics` command.This command requires the caller to have permissions to execute `CF::Control::DiagnosticService::Action::"GetOAuthTokenMetadata"`.
  44dfad5: Added DataStax integration

  ### Patch Changes

  45a493e: Adds additional rate limit handling to OpsGenie resource syncing.
  3e9e52d: Fix issue causing access request flow to get stuck in broken state.Fix issue causing some attributes not to show for resources.
  0914d4e: Fixes an issue which caused the grants to show the message "Error Processing Grant" after a preflight in the Web App when the grant was already active or pending in another request.
  c449aa7: Fixes and issue which prevented using keyboard navigation correctly in the access request UI in the web app when selecting an entitlement
  cfc0974: Update Slack Oauth scopes to match the app definition, fixes an issue causing slack commands not to show for SaaS customers
  080018a: Adds retry handle to accommodate opsgenie ratelimit errors in OpsGenie integration
  387c99d: Requesting access in the UI will now display the duration of the request in the preflight
  0914d4e: Encode the reason into the URL query params for the access request form
  b3d8785: Adds DataStax integration icons to the web console UI.
  5f5e582: Fixes an issue which may have caused PagerDuty sync to fail for some teams

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
