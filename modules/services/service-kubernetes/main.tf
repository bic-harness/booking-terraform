/*
locals {
  config_path            = "${path.module}/../../../config"
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  team_config            = yamldecode(file("${var.config_path}/${var.team_name}/values.yaml"))
  service_config         = yamldecode(file("${var.config_path}/${var.team_name}/services.yaml"))
  var_types = {
    "text" : "TEXT",
    "secret" : "ENCRYPTED_TEXT",
  }
}
*/

data "harness_platform_organization" "this" {
  identifier = var.organization_id
}

data "harness_platform_project" "this" {
  name = "${var.team_name}"
  org_id = data.harness_platform_organization.this.id
}

resource "random_string" "this" {
  length = 4
  special = false
  upper = false
  number = false
}

resource "harness_platform_service" "this" {
  org_id       = data.harness_platform_organization.this.id
  project_id   = data.harness_platform_project.this.id
  name         = var.name
  identifier   = "${var.name}_${random_string.this.result}"

  yaml         = <<-EOT
                  service:
                  name: ${var.name}
                  identifier: K8s_Service
                  tags: {}
                  serviceDefinition:
                    spec:
                      manifests:
                        - manifest:
                            identifier: ${var.name}_${random_string.this.result}
                            type: K8sManifest
                            spec:
                              store:
                                type: Github
                                spec:
                                  connectorRef: account.BCGitAccount
                                  gitFetchType: Branch
                                  paths:
                                    - harness-manifests
                                  repoName: ${var.repo_name}
                                  branch: ${var.branch}
                              valuesPaths:
                                - harness-manifests/values.yaml
                              skipResourceVersioning: true
                              enableDeclarativeRollback: false
                      artifacts:
                        primary:
                          primaryArtifactRef: <+input>
                          sources:
                            - spec:
                                connectorRef: account.harnessImage
                                imagePath: ${var.image}
                                tag: <+input>
                              identifier: ${var.name}_docker_${random_string.this.result}
                              type: DockerRegistry
                      variables:
                        - name: myRepoPath
                          type: String
                          description: "Full Repository Path"
                          value: https://github.com/bic-harness/${var.repo_name}
                    type: Kubernetes
                EOT
}