locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  service_config         = local.app_ci_config["services"][var.service_name]
}

module "artifactsource" {
  source   = "../artifactsource"
  for_each = local.service_config["artifacts"]

  app_ci          = var.app_ci
  name            = each.key
  service_name    = var.service_name
  technology_area = var.technology_area
}

