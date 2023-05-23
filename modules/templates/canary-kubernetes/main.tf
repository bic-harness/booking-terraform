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

resource "harness_platform_template" "this" {
  identifier    = var.name
  org_id        = data.harness_platform_organization.this.id
  project_id    = data.harness_platform_project.this.id
  name          = var.name
  version       = "v1"
  is_stable     = true
  template_yaml = <<-EOT
template:
  name: ${var.name}
  identifier: ${var.name}
  versionLabel: "v1"
  type: ${var.type}
  projectIdentifier: ${data.harness_platform_project.this.id}
  orgIdentifier: ${data.harness_platform_organization.this.id}
  tags: {}
  spec:
    type: Deployment
    spec:
      deploymentType: Kubernetes
      service:
        serviceRef: <+input>
        serviceInputs: <+input>
      environment:
        environmentRef: <+input>
        deployToAll: false
        environmentInputs: <+input>
        serviceOverrideInputs: <+input>
        infrastructureDefinitions: <+input>
      execution:
        steps:
          - stepGroup:
              name: Canary Deployment
              identifier: canaryDepoyment
              steps:
                - step:
                    name: Canary Deployment
                    identifier: canaryDeployment
                    type: K8sCanaryDeploy
                    timeout: 10m
                    spec:
                      instanceSelection:
                        type: Count
                        spec:
                          count: 1
                      skipDryRun: false
                - step:
                    name: Canary Delete
                    identifier: canaryDelete
                    type: K8sCanaryDelete
                    timeout: 10m
                    spec: {}
          - stepGroup:
              name: Primary Deployment
              identifier: primaryDepoyment
              steps:
                - step:
                    name: Rolling Deployment
                    identifier: rollingDeployment
                    type: K8sRollingDeploy
                    timeout: 10m
                    spec:
                      skipDryRun: false
        rollbackSteps:
          - step:
              name: Canary Delete
              identifier: rollbackCanaryDelete
              type: K8sCanaryDelete
              timeout: 10m
              spec: {}
          - step:
              name: Rolling Rollback
              identifier: rollingRollback
              type: K8sRollingRollback
              timeout: 10m
              spec: {}
    failureStrategies:
      - onFailure:
          errors:
            - AllErrors
          action:
            type: StageRollback


  EOT
}
