

output "application_id" {
  value = data.harness_application.this.id
}

output "pipeline_id" {
  value = harness_yaml_config.auto_pipeline.id
}

output "pipeline_name" {
  value = harness_yaml_config.auto_pipeline.name
}
