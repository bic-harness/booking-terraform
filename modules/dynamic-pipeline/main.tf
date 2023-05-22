locals {
  pipeline_name = "${var.environment}_${var.release_id}"
  services      = keys(var.bom)
}

data "template_file" "stage" {
  count = length(local.services)

  template = file("${path.module}/templates/stage.tmpl.yaml")

  vars = {
    serviceName  = local.services[count.index]
    envName      = var.environment
    infraName    = var.infradef
    parallel     = count.index != 0
    workflowName = var.workflow_name
  }
}

data "template_file" "pipeline" {

  template = file("${path.module}/templates/pipeline.tmpl.yaml")

  vars = {
    stages               = join("\n", data.template_file.stage[*].rendered)
    VersionsWorkflowName = harness_yaml_config.build_workflow.name
  }
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

resource "harness_yaml_config" "auto_pipeline" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Pipelines/release_${var.environment}_${var.release_id}.yaml"
  content = data.template_file.pipeline.rendered
}

data "template_file" "artifact" {
  count = length(local.services)

  template = file("${path.module}/templates/collect-artifact.tmpl.yaml")

  vars = {
    serviceName    = local.services[count.index]
    artifactSource = "dev"
    version        = var.bom[local.services[count.index]]
  }
}

data "template_file" "build_workflow" {
  template = file("${path.module}/templates/build.tmpl.yaml")

  vars = {
    steps = join("\n", data.template_file.artifact[*].rendered)
  }
}

resource "harness_yaml_config" "build_workflow" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Workflows/versions_${var.environment}_${var.release_id}.yaml"
  content = data.template_file.build_workflow.rendered
}
