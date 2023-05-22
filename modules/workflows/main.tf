locals {
  config_path            = "${path.module}/../../config"
  template_path          = "${path.module}/../../templates"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  workflows_config       = yamldecode(try(data.utils_deep_merge_yaml.workflow_config.output, {}))
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "utils_deep_merge_yaml" "workflow_config" {
  input = compact([
    yamlencode(try(local.global_config["workflows"], {})),
    yamlencode(try(local.technology_area_config["workflows"], {})),
    yamlencode(try(local.app_ci_config["workflows"], {})),
  ])
}

resource "harness_yaml_config" "workflows" {
  for_each = local.workflows_config
  app_id   = data.harness_application.this.id
  path     = "Setup/Applications/${data.harness_application.this.name}/Workflows/${each.key}.yaml"
  content  = file("${local.template_path}/${each.key}.yaml")
}

