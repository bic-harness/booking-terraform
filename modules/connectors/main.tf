locals {
  config_path            = "${path.module}/../../config"
  connector_config       = yamldecode(file("${local.config_path}/${var.team_name}/connectors.yaml"))
}

data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

data "harness_platform_project" "this" {
  name = "${var.team_name}"
  org_id = data.harness_platform_organization.this.id
}

module "connector_kubernetes" {
  for_each        = local.connector_config
  source          = "./connector-kubernetes"
  organization_id = data.harness_platform_organization.this.id
  team_name       = var.team_name
  name            = each.key
}
