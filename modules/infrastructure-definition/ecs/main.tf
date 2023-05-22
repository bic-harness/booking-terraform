locals {
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  environment_config     = yamldecode(data.utils_deep_merge_yaml.environment.output)
  infra_def_config       = yamldecode(data.utils_deep_merge_yaml.infra_defs.output)
  cloud_provider_name    = "aws-${var.technology_area}-${var.app_ci}-${try(local.infra_def_config["provider"], local.technology_area_config["kubernetes"]["provider"], local.global_config["kubernetes"]["provider"])}"
  namespace              = try(local.infra_def_config["namespace"], local.technology_area_config["kubernetes"]["namespace"], local.global_config["kubernetes"]["namespace"], "${var.app_ci}")
  release_name           = try(local.infra_def_config["release_name"], local.technology_area_config["kubernetes"]["release_name"], local.global_config["kubernetes"]["release_name"], "$${service.name}")

  launch_types = {
    "fargate" : "FARGATE",
  }
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

resource "harness_yaml_config" "fargate" {
  count   = (local.infra_def_config["launch_type"] == "fargate" && try(local.infra_def_config["dynamic"], false) == false) ? 1 : 0
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Environments/${local.infra_def_config["environment"]}/Infrastructure Definitions/${var.name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: INFRA_DEFINITION
cloudProviderType: AWS
deploymentType: ECS
infrastructure:
- type: AWS_ECS
  assignPublicIp: ${try(local.infra_def_config["assign_public_ip"], "false")}
  cloudProviderName: ${local.cloud_provider_name}
  clusterName: ${var.name}
  executionRole: ${try(local.infra_def_config["role"], "")}
  launchType: FARGATE
  region: ${local.infra_def_config["region"]}
  securityGroupIds:
  ${indent(2, yamlencode(try(local.infra_def_config["security_group_ids"], [])))}
  subnetIds:
  ${indent(2, yamlencode(try(local.infra_def_config["subnet_ids"], [])))}
  vpcId: ${local.infra_def_config["vpc"]}
EOF
}

resource "harness_yaml_config" "fargate_dynamic" {
  count   = (local.infra_def_config["launch_type"] == "fargate" && try(local.infra_def_config["dynamic"], false) == true) ? 1 : 0
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Environments/${local.infra_def_config["environment"]}/Infrastructure Definitions/${var.name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: INFRA_DEFINITION
cloudProviderType: AWS
deploymentType: ECS
infrastructure:
- type: AWS_ECS
  assignPublicIp: ${try(local.infra_def_config["assign_public_ip"], "false")}
  cloudProviderName: ${local.cloud_provider_name}
  expressions:
    securityGroupIds: ${try(local.infra_def_config["security_group_ids"], "")}
    vpcId: ${local.infra_def_config["vpc"]}
    clusterName: ${var.name}
    executionRole: ${try(local.infra_def_config["role"], "")}
    region: ${local.infra_def_config["region"]}
    subnetIds: ${try(local.infra_def_config["subnet_ids"], "")}
  launchType: FARGATE
provisioner: ${try(local.infra_def_config["provisioner"], "")}
EOF
}
