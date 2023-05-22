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
  identifier: ${var.name}_${random_string.this.result}
  tags: {}
  serviceDefinition:
    spec:
      manifests:
        - manifest:
            identifier: HelloWorld
            type: K8sManifest
            spec:
              store:
                type: Github
                spec:
                  connectorRef: account.BCGitAccount
                  gitFetchType: Branch
                  paths:
                    - harness-manifests
                  repoName: docker-hello-world
                  branch: master
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
                imagePath: bicharness/helloworld
                tag: <+input>
              identifier: HelloWorld
              type: DockerRegistry
      variables:
        - name: myVariable
          type: String
          description: ""
          value: myValue
    type: Kubernetes
EOT
}