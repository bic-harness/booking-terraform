locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provider_configs       = yamldecode(data.utils_deep_merge_yaml.provider_configs.output)
}

data "utils_deep_merge_yaml" "provider_configs" {
  input = compact([
    yamlencode(try(local.global_config["providers"], {})),
    yamlencode(try(local.technology_area_config["providers"], {})),
    yamlencode(try(local.app_ci_config["providers"], {})),
  ])
}

module "cloudprovider" {
  source          = "../cloudprovider"
  for_each        = local.provider_configs
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = each.key
}

