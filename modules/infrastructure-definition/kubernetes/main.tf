locals {
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  environment_config     = yamldecode(data.utils_deep_merge_yaml.environment.output)
  infra_def_config       = yamldecode(data.utils_deep_merge_yaml.infra_defs.output)

  cloud_provider_name = "eks-${var.technology_area}-${var.app_ci}-${local.infra_def_config["environment"]}-${try(local.infra_def_config["provider"], local.technology_area_config["kubernetes"]["provider"], local.global_config["kubernetes"]["provider"])}"
  namespace           = try(local.infra_def_config["namespace"], local.technology_area_config["kubernetes"]["namespace"], local.global_config["kubernetes"]["namespace"], "${var.app_ci}")
  release_name        = try(local.infra_def_config["release_name"], local.technology_area_config["kubernetes"]["release_name"], local.global_config["kubernetes"]["release_name"], "$${service.name}")
}

data "utils_deep_merge_yaml" "environment" {
  input = compact([
    yamlencode(try(local.global_config["environments"][local.infra_def_config["environment"]], {})),
    yamlencode(try(local.technology_area_config["environments"][local.infra_def_config["environment"]], {})),
    yamlencode(try(local.app_ci_config["environments"][local.infra_def_config["environment"]], {})),
  ])
}

data "utils_deep_merge_yaml" "infra_defs" {
  input = compact([
    yamlencode(try(local.global_config["infrastructure"][var.name], {})),
    yamlencode(try(local.technology_area_config["infrastructure"][var.name], {})),
    yamlencode(try(local.app_ci_config["infrastructure"][var.name], {})),
  ])
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

resource "harness_yaml_config" "this" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Environments/${local.infra_def_config["environment"]}/Infrastructure Definitions/${var.name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: INFRA_DEFINITION
cloudProviderType: KUBERNETES_CLUSTER
deploymentType: KUBERNETES
infrastructure:
- type: DIRECT_KUBERNETES
  cloudProviderName: ${local.cloud_provider_name}
  namespace: ${local.namespace}
  releaseName: ${local.release_name}
EOF
}
