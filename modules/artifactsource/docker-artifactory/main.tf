locals {
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  service_config         = local.app_ci_config["services"][var.service_name]
  artifact_config        = yamldecode(data.utils_deep_merge_yaml.artifact_config.output)
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "utils_deep_merge_yaml" "artifact_config" {
  input = compact([
    yamlencode(try(local.global_config["artifacts"]["docker_artifactory"], {})),
    yamlencode(try(local.technology_area_config["artifacts"]["docker_artifactory"], {})),
    yamlencode(try(local.app_ci_config["artifacts"]["docker_artifactory"], {})),
    yamlencode(try(local.service_config["artifacts"][var.name], {})),
  ])
}

resource "harness_yaml_config" "this" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Services/${var.service_name}/Artifact Servers/${var.name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: ARTIFACTORY
dockerRepositoryServer: ${local.artifact_config["server"]}
imageName: ${local.artifact_config["image"]}
metadataOnly: true
repositoryName: ${local.artifact_config["repository"]}
repositoryType: docker
serverName: ${local.artifact_config["connector"]}
useDockerFormat: false
EOF
}
