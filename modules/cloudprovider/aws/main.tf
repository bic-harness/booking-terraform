locals {
  global_config          = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provider_config        = yamldecode(data.utils_deep_merge_yaml.provider_config.output)
  environment_config     = yamldecode(data.utils_deep_merge_yaml.environment.output)
  use_cross_account_role = try(local.provider_config["sts_role"], "") != ""
  cross_account_role     = <<EOF
crossAccountAttributes:
  crossAccountRoleArn: ${try(local.provider_config["sts_role"], "")}
EOF

  env_types = {
    "nonprod" : "NON_PROD",
    "prod" : "PROD",
  }

  expanded_env_types = {
    "nonprod" : "NON_PRODUCTION_ENVIRONMENTS",
    "prod" : "PRODUCTION_ENVIRONMENTS",
  }
  name = "aws-${var.technology_area}-${var.app_ci}-${local.provider_config.environment}"
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}


data "harness_environment" "this" {
  app_id = data.harness_application.this.id
  name   = local.provider_config["environment"]
}

data "utils_deep_merge_yaml" "provider_config" {
  input = compact([
    yamlencode(try(local.global_config["providers"][var.name], {})),
    yamlencode(try(local.technology_area_config["providers"][var.name], {})),
    yamlencode(try(local.app_ci_config["providers"][var.name], {})),
  ])
}

data "utils_deep_merge_yaml" "environment" {
  input = compact([
    yamlencode(try(local.global_config["environments"][local.provider_config["environment"]], {})),
    yamlencode(try(local.technology_area_config["environments"][local.provider_config["environment"]], {})),
    yamlencode(try(local.app_ci_config["environments"][local.provider_config["environment"]], {})),
  ])
}


resource "harness_yaml_config" "this" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Cloud Providers/${local.name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: AWS
assumeCrossAccountRole: true
${local.use_cross_account_role ? local.cross_account_role : ""}
tag: ${lower(var.technology_area)}-${local.environment_config["type"]}
usageRestrictions:
  appEnvRestrictions:
  - appFilter:
      entityNames:
      - ${data.harness_application.this.name}
      filterType: SELECTED
    envFilter:
      entityNames:
      - ${data.harness_environment.this.name}
      filterTypes:
      - SELECTED
useEc2IamCredentials: true
useIRSA: false
EOF
}
