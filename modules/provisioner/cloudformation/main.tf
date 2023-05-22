locals {
  global_config           = yamldecode(file("${var.config_path}/values.yaml"))
  technology_area_config  = yamldecode(file("${var.config_path}/${var.technology_area}/values.yaml"))
  app_ci_config           = yamldecode(file("${var.config_path}/${var.technology_area}/${var.app_ci}.yaml"))
  provisioner_config      = yamldecode(data.utils_deep_merge_yaml.provisioner_config.output)
  default_secrets_manager = "Harness Secrets Manager - GCP KMS"
  secret_manager          = try(local.provisioner_config["secret_manager"], local.default_secrets_manager)
  variables_config        = try(local.provisioner_config["variables"], {})
  variables_keys          = keys(try(local.variables_config["variables"], {}))
  var_types = {
    "text" : "TEXT",
    "secret" : "ENCRYPTED_TEXT",
  }
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

data "harness_git_connector" "this" {
  name = local.provisioner_config["connector"]
}

data "template_file" "variables" {
  count    = length(local.variables_keys)
  template = <<EOF
- name: ${local.variables_config[local.variables_keys[count.index]]}
  valueType: ${local.var_types[local.variables_keys[count.index]]}
EOF
}

resource "harness_yaml_config" "this" {
  app_id  = data.harness_application.this.id
  path    = "Setup/Applications/${data.harness_application.this.name}/Provisioners/${var.name}.yaml"
  content = <<EOF
harnessApiVersion: '1.0'
type: CLOUD_FORMATION
gitFileConfig:
  branch: ${local.provisioner_config["branch"]}
  connectorId: ${data.harness_git_connector.this.id}
  filePath: ${local.provisioner_config["path"]}
  useBranch: true
  useInlineServiceDefinition: false
sourceType: GIT
variables:
${join("\n", data.template_file.variables[*].rendered)}
EOF
}
