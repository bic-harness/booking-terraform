locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provider_config        = yamldecode(data.utils_deep_merge_yaml.provider_config.output)
}

data "utils_deep_merge_yaml" "provider_config" {
  input = compact([
    yamlencode(try(local.global_config["providers"][var.name], {})),
    yamlencode(try(local.technology_area_config["providers"][var.name], {})),
    yamlencode(try(local.app_ci_config["providers"][var.name], {})),
  ])
}

module "kubernetes" {
  source          = "./kubernetes"
  count           = local.provider_config["type"] == "kubernetes" ? 1 : 0
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}

module "aws" {
  source          = "./aws"
  count           = local.provider_config["type"] == "aws" ? 1 : 0
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}
