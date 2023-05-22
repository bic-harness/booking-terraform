locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  service_config         = local.app_ci_config["services"][var.name]
}

module "kubernetes" {
  source          = "./service-kubernetes"
  count           = local.service_config["type"] == "kubernetes" ? 1 : 0
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}

module "ecs" {
  source          = "./service-ecs"
  count           = local.service_config["type"] == "ecs" ? 1 : 0
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}

module "artifactsources" {
  source = "../artifactsources"
  depends_on = [
    module.kubernetes[0],
    module.ecs[0]
  ]

  technology_area = var.technology_area
  app_ci          = var.app_ci
  service_name    = var.name
}
