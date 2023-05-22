locals {
  global_config           = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config  = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config           = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provisioner_config      = yamldecode(data.utils_deep_merge_yaml.provisioner_config.output)
  default_secrets_manager = "Harness Secrets Manager - GCP KMS"
  secret_manager          = try(local.provisioner_config["secret_manager"], local.default_secrets_manager)
}

data "harness_application" "this" {
  name = "${var.technology_area}-${var.app_ci}"
}

data "utils_deep_merge_yaml" "provisioner_config" {
  input = compact([
    yamlencode(try(local.global_config["provisioners"][var.name], {})),
    yamlencode(try(local.technology_area_config["provisioners"][var.name], {})),
    yamlencode(try(local.app_ci_config["provisioners"][var.name], {})),
  ])
}

resource "harness_yaml_config" "this" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Provisioners/${var.name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: TERRAFORM
path: ${local.provisioner_config["path"]}
secretMangerName: ${local.secret_manager}
skipRefreshBeforeApplyingPlan: ${local.provisioner_config["skip_refresh"]}
sourceRepoBranch: ${local.provisioner_config["branch"]}
sourceRepoSettingName: ${local.provisioner_config["connector"]}
EOF
}
