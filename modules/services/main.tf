locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
}

module "service" {
  source          = "../service"
  for_each        = local.app_ci_config["services"]
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = each.key
}


