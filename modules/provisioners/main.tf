locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provisioners_config    = yamldecode(data.utils_deep_merge_yaml.provisioners_config.output)
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "utils_deep_merge_yaml" "provisioners_config" {
  input = compact([
    yamlencode(try(local.global_config["provisioners"], {})),
    yamlencode(try(local.technology_area_config["provisioners"], {})),
    yamlencode(try(local.app_ci_config["provisioners"], {})),
  ])
}

module "provisioner-terraform" {
  source          = "../provisioner"
  for_each        = local.provisioners_config
  name            = each.key
  technology_area = var.technology_area
  app_ci          = var.app_ci
  type            = each.value["type"]
}
