/*
locals {
  config_path            = "${path.module}/../../../config"
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  team_config            = yamldecode(file("${var.config_path}/${var.team_name}/values.yaml"))
  service_config         = yamldecode(file("${var.config_path}/${var.team_name}/services.yaml"))
  var_types = {
    "text" : "TEXT",
    "secret" : "ENCRYPTED_TEXT",
  }
}
*/

data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

data "harness_platform_project" "this" {
  name = "${var.team_name}"
  org_id = data.harness_platform_organization.this.id
}

resource "harness_platform_environment" "this" {
  org_id       = data.harness_platform_organization.this.id
//  project_id   = data.harness_platform_project.this.id
  name         = var.name
  identifier   = var.name
  type         = var.type
}