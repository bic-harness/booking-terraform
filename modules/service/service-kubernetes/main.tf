locals {
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  service_config         = local.app_ci_config["services"][var.name]
  variables_config       = yamldecode(try(data.utils_deep_merge_yaml.variables[0].output, "{}"))
  tier                   = try(local.service_config["tier"], "")
  manifest_config        = yamldecode(data.utils_deep_merge_yaml.manifest.output)
  overrides_config       = try(local.manifest_config["overrides"], {})

  var_types = {
    "text" : "TEXT",
    "secret" : "ENCRYPTED_TEXT",
  }

  namespace_types = {
    "frontend" : "${lower(var.app_ci)}-ui",
    "backend" : "${lower(var.app_ci)}-service",
  }
}

data "utils_deep_merge_yaml" "variables" {
  count = local.tier != "" ? 1 : 0

  input = compact([
    yamlencode(
      {
        namespace : {
          value : "${local.namespace_types[local.tier]}",
          type : "text",
        }
    }),
    yamlencode(try(local.service_config["variables"], {})),
  ])
}

data "utils_deep_merge_yaml" "manifest" {
  input = compact([
    yamlencode(try(local.global_config["manifests"]["kubernetes"], {})),
    yamlencode(try(local.technology_area_config["manifests"]["kubernetes"], {})),
    yamlencode(try(local.app_ci_config["manifests"]["kubernetes"], {})),
    yamlencode(try(local.service_config["manifest"], {})),
  ])
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

output "config" {
  value = local.manifest_config
}

resource "harness_service_kubernetes" "this" {
  app_id       = data.harness_application.this.id
  name         = var.name
  helm_version = try(local.service_config["helm_version"], "V3")
  description  = try(local.service_config["description"], "")

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
  path    = "Setup/Applications/${data.harness_application.this.name}/Services/${harness_service_kubernetes.this.name}/Manifests/Index.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: APPLICATION_MANIFEST
gitFileConfig:
  branch: ${try(local.manifest_config["branch"], "master")}
  connectorName: ${local.manifest_config["connector"]}
  filePath: ${try(local.manifest_config["path"], "")}
  repoName: ${try(local.manifest_config["repo"], "")}
  useBranch: true
  useInlineServiceDefinition: false
storeType: HelmSourceRepo
EOF
}

resource "harness_yaml_config" "values_remote" {
  count   = try(local.overrides_config["type"], "") == "remote" ? 1 : 0
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Services/${harness_service_kubernetes.this.name}/Values/Index.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: APPLICATION_MANIFEST
gitFileConfig:
  branch: ${try(local.overrides_config["branch"], local.global_config["overrides"]["branch"], "master")}
  connectorName: ${try(local.overrides_config["connector"], local.global_config["overrides"]["connector"])}
  filePath: ${try(local.overrides_config["path"], local.global_config["overrides"]["path"])}
  repoName: ${try(local.overrides_config["repo"], local.global_config["overrides"]["repo"])}
  useBranch: true
  useInlineServiceDefinition: false
storeType: Remote
EOF
}

resource "harness_yaml_config" "values_inline_index" {
  count = try(local.overrides_config["type"], "") == "inline" ? 1 : 0

  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Services/${harness_service_kubernetes.this.name}/Values/Index.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: APPLICATION_MANIFEST
storeType: Local
EOF
}

resource "harness_yaml_config" "values_inline" {
  count      = try(local.overrides_config["type"], "") == "inline" ? 1 : 0
  depends_on = [harness_yaml_config.values_inline_index[0]]

  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Services/${harness_service_kubernetes.this.name}/Values/values.yaml"
  content = try(local.overrides_config["values"], "")
}
