locals {
  config_path            = "${path.module}/../../config"
  infradefs_config       = yamldecode(file("${local.config_path}/${var.team_name}/infradefs.yaml"))
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

module "kubernetes" {
  for_each        = local.infradefs_config
  source          = "./infra-kubernetes"
  organization_id = data.harness_platform_organization.this.id
  team_name       = var.team_name
  name            = each.key
  env             = each.value.environment
  type            = each.value.type
  connector       = "${each.value.connector}_${var.connector_random_string}"
  namespace       = each.value.namespace
}