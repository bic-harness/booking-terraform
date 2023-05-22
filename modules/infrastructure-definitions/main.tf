locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  infra_defs             = yamldecode(data.utils_deep_merge_yaml.infra_defs.output)
}

data "utils_deep_merge_yaml" "infra_defs" {
  input = compact([
    yamlencode(try(local.global_config["infrastructure"], {})),
    yamlencode(try(local.technology_area_config["infrastructure"], {})),
    yamlencode(try(local.app_ci_config["infrastructure"], {})),
  ])
}

output "config" {
  value = local.infra_defs
}

module "infrastructure_def" {
  source   = "../infrastructure-definition"
  for_each = local.infra_defs

  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = each.key
}
