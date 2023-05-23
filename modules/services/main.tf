locals {
  config_path            = "${path.module}/../../config"
  service_config         = yamldecode(file("${local.config_path}/${var.team_name}/services.yaml"))
}

data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

data "harness_platform_project" "this" {
  name = "${var.team_name}"
  org_id = data.harness_platform_organization.this.id
}

module "kubernetes" {
  for_each        = local.service_config
  source          = "./service-kubernetes"
  organization_id = data.harness_platform_organization.this.id
  team_name       = var.team_name
  name            = each.key
  repo_name       = each.value.repoName
  branch          = each.value.branch
  image           = each.value.image
}
