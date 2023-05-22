locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  team_config            = yamldecode(file("${var.config_path}/${var.team_name}/values.yaml"))
  service_config         = yamldecode(file("${var.config_path}/${var.team_name}/services.yaml"))
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
  source          = "./service-kubernetes"
  for_each        = local.service_config
  organization_id = data.harness_platform_organization.this.id
  team_name       = var.team_name
  name            = each.key
  repo_name       = each.value.repoName
  branch          = each.value.branch
  image           = each.value.image
}
