locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  team_config            = yamldecode(file("${local.config_path}/${var.team_name}/values.yaml"))
}

data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

// This is a hack to get around the soft-delete problem with Harness.
resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "harness_platform_project" "this" {
  identifier = "${var.team_name}_${random_string.this.result}"
  name       = "${var.team_name}"
  org_id     = data.harness_platform_organization.this.id
}
