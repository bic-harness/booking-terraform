locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  service_config         = local.app_ci_config["services"][var.service_name]
  artifact_config        = yamldecode(data.utils_deep_merge_yaml.artifact_config.output)
  artifact_type          = local.service_config["artifacts"][var.name]["type"]
  trigger_config         = yamldecode(data.utils_deep_merge_yaml.trigger_config.output)
  auto_trigger           = try(local.artifact_config["auto_trigger"], false)

  resource_types = {
    "workflow" : "Workflow",
    "pipeline" : "Pipeline",
  }
}

data "utils_deep_merge_yaml" "artifact_config" {
  input = compact([
    yamlencode(try(local.global_config["artifacts"][local.artifact_type], {})),
    yamlencode(try(local.technology_area_config["artifacts"][local.artifact_type], {})),
    yamlencode(try(local.app_ci_config["artifacts"][local.artifact_type], {})),
    yamlencode(try(local.service_config["artifacts"][var.name], {})),
  ])
}

data "utils_deep_merge_yaml" "trigger_config" {
  input = compact([
    yamlencode(try(local.global_config["artifacts"][local.artifact_type]["trigger"], {})),
    yamlencode(try(local.technology_area_config["artifacts"][local.artifact_type]["trigger"], {})),
    yamlencode(try(local.artifact_config["trigger"], {})),
  ])
}


module "docker_registry_artifactsource" {
  count  = local.artifact_config["type"] == "docker_registry" ? 1 : 0
  source = "./docker-registry"

  technology_area = var.technology_area
  app_ci          = var.app_ci
  service_name    = var.service_name
  name            = var.name
  config_path     = local.config_path
}

module "docker_artifactory_artifactsource" {
  count  = local.artifact_config["type"] == "docker_artifactory" ? 1 : 0
  source = "./docker-artifactory"

  technology_area = var.technology_area
  app_ci          = var.app_ci
  service_name    = var.service_name
  name            = var.name
  config_path     = local.config_path
}


module "auto_trigger" {
  count  = local.auto_trigger == true ? 1 : 0
  source = "../trigger-new-artifact"
  depends_on = [
    module.docker_registry_artifactsource[0],
    module.docker_artifactory_artifactsource[0],
  ]

  technology_area                = var.technology_area
  app_ci                         = var.app_ci
  resource_name                  = local.trigger_config["name"]
  resource_type                  = local.resource_types[lower(local.trigger_config["type"])]
  service_name                   = var.service_name
  artifactsource_name            = var.name
  infrastructure_definition_name = local.trigger_config["env"]["infra"]
  environment_name               = local.trigger_config["env"]["name"]
}
