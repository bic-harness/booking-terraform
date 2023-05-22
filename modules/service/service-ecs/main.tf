locals {
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  service_config         = local.app_ci_config["services"][var.name]
  variables_config       = yamldecode(try(data.utils_deep_merge_yaml.variables.output, "{}"))
  tier                   = try(local.service_config["tier"], "")
  manifest_config        = yamldecode(data.utils_deep_merge_yaml.manifest.output)

  var_types = {
    "text" : "TEXT",
    "secret" : "ENCRYPTED_TEXT",
  }

  namespace_types = {
    "frontend" : "${lower(var.app_ci)}-ui",
    "backend" : "${lower(var.app_ci)}-service",
  }
}

data "utils_deep_merge_yaml" "tier" {
  count = local.tier != "" ? 1 : 0

  input = compact([
    yamlencode(
      {
        namespace : {
          value : "${local.namespace_types[local.tier]}",
          type : "text",
        }
    }),
  ])
}

data "utils_deep_merge_yaml" "variables" {
  input = compact([
    yamlencode(try(local.global_config["services"]["ecs"]["variables"], {})),
    yamlencode(try(local.technology_area_config["services"]["ecs"]["variables"], {})),
    try(data.utils_deep_merge_yaml.tier[0].output, "{}"),
    yamlencode(try(local.service_config["variables"], {})),
  ])
}


data "utils_deep_merge_yaml" "manifest" {
  input = compact([
    yamlencode(try(local.global_config["manifests"]["ecs"], {})),
    yamlencode(try(local.technology_area_config["manifests"]["ecs"], {})),
    yamlencode(try(local.app_ci_config["manifests"]["ecs"], {})),
    yamlencode(try(local.service_config["manifest"], {})),
  ])
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

resource "harness_service_ecs" "this" {
  app_id      = data.harness_application.this.id
  name        = var.name
  description = try(local.service_config["description"], "")

  dynamic "variable" {
    for_each = local.variables_config

    content {
      name  = variable.key
      value = variable.value["value"]
      type  = local.var_types[variable.value["type"]]
    }
  }
}

resource "harness_yaml_config" "manifest" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Services/${harness_service_ecs.this.name}/Manifests/Index.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: APPLICATION_MANIFEST
gitFileConfig:
  branch: ${try(local.manifest_config["branch"], "master")}
  connectorName: ${local.manifest_config["connector"]}
  serviceSpecFilePath: ${local.manifest_config["service_definition_path"]}
  taskSpecFilePath: ${local.manifest_config["task_definition_path"]}
  useBranch: true
  useInlineServiceDefinition: false
storeType: Remote
EOF
}
