locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  environment_config     = yamldecode(data.utils_deep_merge_yaml.environment.output)

  env_type = {
    "nonprod" : "NON_PROD",
    "prod" : "PROD",
  }

  var_type = {
    "text" : "TEXT",
    "secret" : "ENCRYPTED_TEXT",
  }

}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "utils_deep_merge_yaml" "environment" {
  input = compact([
    yamlencode(try(local.global_config["environments"][var.name], {})),
    yamlencode(try(local.technology_area_config["environments"][var.name], {})),
    yamlencode(try(local.app_ci_config["environments"][var.name], {})),
  ])
}

resource "harness_environment" "this" {
  app_id = data.harness_application.this.id
  name   = var.name
  type   = local.env_type[local.environment_config.type]

  dynamic "variable_override" {
    for_each = try(local.environment_config["variables"], {})

    content {
      name         = variable_override.key
      value        = variable_override.value["value"]
      service_name = try(variable_override.value["service"], "")
      type         = local.var_type[variable_override.value["type"]]
    }
  }

}
