locals {
  config_path            = "${path.module}/../../config"
  envs_config            = yamldecode(file("${local.config_path}/${var.team_name}/environments.yaml"))
}

data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

data "harness_platform_project" "this" {
  name = "${var.team_name}"
  org_id = data.harness_platform_organization.this.id
}

resource "random_string" "this" {
  length = 4
  special = false
  upper = false
  number = false
}

module "environment" {
  for_each        = local.service_config
  source          = "./environment"
  organization_id = data.harness_platform_organization.this.id
  team_name       = var.team_name
  name            = each.key
  type            = each.value.type
}
