locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provisioner_config     = yamldecode(data.utils_deep_merge_yaml.provisioner_config.output)
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "utils_deep_merge_yaml" "provisioner_config" {
  input = compact([
    yamlencode(try(local.global_config["provisioners"][var.name], {})),
    yamlencode(try(local.technology_area_config["provisioners"][var.name], {})),
    yamlencode(try(local.app_ci_config["provisioners"][var.name], {})),
  ])
}

module "terraform" {
  source          = "./terraform"
  count           = local.provisioner_config["type"] == "terraform" ? 1 : 0
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}

module "cloudformation" {
  source          = "./cloudformation"
  count           = local.provisioner_config["type"] == "cloudformation" ? 1 : 0
  technology_area = var.technology_area
  app_ci          = var.app_ci
  name            = var.name
  config_path     = local.config_path
}
