provider "google" {
  project = var.gcp_project
}

resource "google_iam_workload_identity_pool" "this" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = var.workload_identity_pool_display_name
  description               = "Identity Pool for Common Fate GCP Integration"
}

resource "google_iam_workload_identity_pool_provider" "this" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_pool_provider_id

  display_name = var.workload_identity_pool_provider_display_name
  description  = "Common Fate AWS Deployment Account Provider"
  attribute_mapping = {
    "google.subject"        = "assertion.arn"
    "attribute.aws_account" = "assertion.account"
    "attribute.aws_role"    = "assertion.arn.contains('assumed-role') ? assertion.arn.extract('{account_arn}assumed-role/') + 'assumed-role/'  + assertion.arn.extract('assumed-role/{role_name}/') : assertion.arn",
  }

  aws {
    account_id = var.common_fate_aws_account_id
  }

}

#######################################################
# GCP Read Role
# used for reading resources
#######################################################
resource "google_organization_iam_custom_role" "read" {
  role_id     = var.gcp_reader_iam_role_id
  org_id      = var.gcp_organization_id
  title       = "Common Fate Read"
  description = "Common Fate read-only role which allows reading GCP resources"
  permissions = [
    "iam.roles.get",
    "iam.roles.list",
    "resourcemanager.folders.get",
    "resourcemanager.folders.getIamPolicy",
    "resourcemanager.folders.list",
    "resourcemanager.organizations.getIamPolicy",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.organizations.get",
    "resourcemanager.projects.get",
    "resourcemanager.projects.list",
    "resourcemanager.tagKeys.list",
    "resourcemanager.tagValues.list",
    "resourcemanager.hierarchyNodes.listEffectiveTags",
    "resourcemanager.hierarchyNodes.listTagBindings",
    "cloudasset.assets.listResource"
  ]
}

resource "google_service_account" "read" {
  account_id   = var.gcp_reader_service_account_id
  display_name = "Common Fate Read"
}

resource "google_organization_iam_binding" "read" {
  org_id = var.gcp_organization_id
  role   = google_organization_iam_custom_role.read.id

  members = [
    "serviceAccount:${google_service_account.read.email}"
  ]
}

resource "google_service_account_iam_binding" "read" {
  service_account_id = google_service_account.read.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/attribute.aws_role/arn:aws:sts::${var.common_fate_aws_account_id}:assumed-role/${var.common_fate_aws_reader_role_name}"
  ]
}


locals {
  base_provision_permissions = [
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "resourcemanager.folders.getIamPolicy",
    "resourcemanager.folders.setIamPolicy"
  ]

  bigquery_permissions = var.permit_bigquery_provisioning == true ? [
    "bigquery.tables.getIamPolicy",
    "bigquery.tables.setIamPolicy",
    "bigquery.datasets.getIamPolicy",
    "bigquery.datasets.setIamPolicy"
  ] : []

  organization_permissions = var.permit_organization_provisioning == true ? [
    "resourcemanager.organizations.getIamPolicy",
    "resourcemanager.organizations.setIamPolicy",
  ] : []

  provision_permissions = concat(
    local.base_provision_permissions,
    local.bigquery_permissions,
    local.organization_permissions,
  )
}

#######################################################
# GCP Provision Role
# used for provisioning access to entitlements
#######################################################
resource "google_organization_iam_custom_role" "provision" {
  role_id     = var.gcp_provisioner_iam_role_id
  org_id      = var.gcp_organization_id
  title       = "Common Fate Provision"
  description = "Common Fate provisioner role which allows assigning entitlements"
  permissions = provision_permissions
}

resource "google_service_account" "provision" {
  account_id   = var.gcp_provisioner_service_account_id
  display_name = "Common Fate Provision"
}

resource "google_organization_iam_binding" "provision" {
  org_id = var.gcp_organization_id
  role   = google_organization_iam_custom_role.provision.id

  members = [
    "serviceAccount:${google_service_account.provision.email}"
  ]
}

resource "google_service_account_iam_binding" "provision" {
  service_account_id = google_service_account.provision.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/attribute.aws_role/arn:aws:sts::${var.common_fate_aws_account_id}:assumed-role/${var.common_fate_aws_provisioner_role_name}"
  ]
}
