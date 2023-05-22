locals {
  config_path            = "${path.module}/../../config"
  global_config          = yamldecode(file("${local.config_path}/values.yaml"))
  technology_area_config = yamldecode(file("${local.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config          = yamldecode(file("${local.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  app_config             = try(local.app_ci_config["app_config"], {})
  app_config_keys        = keys(local.app_config)
}

resource "harness_application" "this" {
  name        = "${var.technology_area}-${var.app_ci}"
  description = "Managed by Harness Terraform"

  tags = ["technology_area:${var.technology_area}", "app_ci:${var.app_ci}"]
}

data "template_file" "config" {
  count    = length(local.app_config_keys)
  template = <<EOF
- name: ${local.app_config_keys[count.index]}
  value: ${local.app_config[local.app_config_keys[count.index]]}
EOF
}


resource "harness_yaml_config" "defaults" {
  app_id  = harness_application.this.id
  path    = "Setup/Applications/${harness_application.this.name}/Defaults.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: APPLICATION_DEFAULTS
defaults:
- name: TechnologyArea
  value: ${var.technology_area}
- name: AppCI
  value: ${var.app_ci}
- name: BACKUP_PATH
  value: $$HOME/$${app.name}/$${service.name}/$${env.name}/backup/$${timestampId}
- name: RUNTIME_PATH
  value: $$HOME/$${app.name}/$${service.name}/$${env.name}/runtime
- name: STAGING_PATH
  value: $$HOME/$${app.name}/$${service.name}/$${env.name}/staging/$${timestampId}
- name: WINDOWS_RUNTIME_PATH
  value: '%USERPROFILE%\$${app.name}\$${service.name}\$${env.name}\runtime'
${join("\n", data.template_file.config[*].rendered)}
EOF
}


