locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  environments_config    = yamldecode(data.utils_deep_merge_yaml.environments.output)
}

data "utils_deep_merge_yaml" "environments" {
  input = compact([
    yamlencode(try(local.global_config["environments"], {})),
    yamlencode(try(local.technology_area_config["environments"], {})),
    yamlencode(try(local.app_ci_config["environments"], {})),
  ])
}

module "environment" {
  source          = "../environment"
  for_each        = local.environments_config
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = each.key
}
