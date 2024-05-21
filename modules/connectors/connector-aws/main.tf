data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

data "harness_platform_project" "this" {
  name = "${var.team_name}"
  org_id = data.harness_platform_organization.this.id
}

resource "harness_platform_connector_aws" "this" {
  identifier  = var.identifier
  name        = var.name

  manual {
    access_key_ref = "account.nextGenAWSAccessKey"
    secret_key_ref = "account.nextGenSecretKey"
  }
}