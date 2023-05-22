locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  infra_def_config       = yamldecode(data.utils_deep_merge_yaml.infra_defs.output)[var.name]
}

data "utils_deep_merge_yaml" "infra_defs" {
  input = compact([
    yamlencode(try(local.global_config["infrastructure"], {})),
    yamlencode(try(local.technology_area_config["infrastructure"], {})),
    yamlencode(try(local.app_ci_config["infrastructure"], {})),
  ])
}

output "config" {
  value = local.infra_def_config
}

module "kubernetes" {
  source = "./kubernetes"
  count  = local.infra_def_config["type"] == "kubernetes" ? 1 : 0

  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}


module "ecs" {
  source = "./ecs"
  count  = local.infra_def_config["type"] == "ecs" ? 1 : 0

  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}
