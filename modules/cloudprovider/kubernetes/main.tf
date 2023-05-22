locals {
  global_config           = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config  = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config           = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provider_config         = yamldecode(data.utils_deep_merge_yaml.provider_config.output)
  environment_config      = yamldecode(data.utils_deep_merge_yaml.environment.output)
  default_secrets_manager = "Harness Secrets Manager - GCP KMS"
  secret_manager          = try(local.provider_config["secret_manager"], local.default_secrets_manager)

  env_types = {
    "nonprod" : "NON_PROD",
    "prod" : "PROD",
  }

  expanded_env_types = {
    "nonprod" : "NON_PRODUCTION_ENVIRONMENTS",
    "prod" : "PRODUCTION_ENVIRONMENTS",
  }
  name = "eks-${var.technology_area}-${var.app_ci}-${local.provider_config.environment}-${var.name}"
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "harness_secret_manager" "this" {
  name = local.secret_manager
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
type: KUBERNETES_CLUSTER
authType: SERVICE_ACCOUNT
continuousEfficiencyConfig:
  continuousEfficiencyEnabled: false
masterUrl: ${local.provider_config.master_url}
serviceAccountToken: secretName:${harness_encrypted_text.this.name}
skipValidation: true
useKubernetesDelegate: false
EOF
}

resource "harness_encrypted_text" "this" {
  name              = "${local.name}-token"
  value             = "REPLACE_ME"
  secret_manager_id = data.harness_secret_manager.this.id

  usage_scope {
    application_id = data.harness_application.this.id
    environment_id = data.harness_environment.this.id
  }

  lifecycle {
    ignore_changes = [value]
  }

}
