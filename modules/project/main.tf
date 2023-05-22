locals {
  config_path            = "../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
}

data "harness_platform_organization" "this" {
  name = var.organization_id
}

// This is a hack to get around the soft-delete problem with Harness.
resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
  number  = false
}

resource "harness_platform_project" "this" {
  identifier = "${var.technology_area}_${var.app_ci}_${random_string.this.result}"
  name       = "${var.technology_area}-${var.app_ci}"
  org_id     = data.harness_platform_organization.this.id
}
