locals {
  config_path            = "${path.module}/../../config"
  k8s_connector_config   = yamldecode(file("${local.config_path}/${var.team_name}/K8s/connectors.yaml"))
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

module "connector_kubernetes" {
  for_each        = local.k8s_connector_config
  source          = "./connector-kubernetes"
  organization_id = data.harness_platform_organization.this.id
  team_name       = var.team_name
  name            = each.key
  identifier      = "${each.key}_${random_string.this.result}"
}
