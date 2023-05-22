locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  trigger_name           = "${var.service_name}-${var.artifactsource_name}-new-artifact"
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

resource "harness_yaml_config" "this" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Triggers/${local.trigger_name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: TRIGGER
artifactSelections:
- regex: false
  serviceName: ${var.service_name}
  type: ARTIFACT_SOURCE
continueWithDefaultValues: false
executionName: ${var.resource_name}
executionType: ${var.resource_type}
triggerCondition:
- type: NEW_ARTIFACT
  artifactStreamName: ${var.artifactsource_name}
  regex: false
  serviceName: ${var.service_name}
workflowVariables:
- entityType: ENVIRONMENT
  name: Environment
  value: ${var.environment_name}
- entityType: SERVICE
  name: Service
  value: ${var.service_name}
- entityType: INFRASTRUCTURE_DEFINITION
  name: InfraDefinition_KUBERNETES
  value: ${var.infrastructure_definition_name}

EOF
}
