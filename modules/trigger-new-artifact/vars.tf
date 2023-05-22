variable "technology_area" {
  description = "The UAL Technology Area."
}

variable "app_ci" {
  description = "The UAL AppCI."
}

variable "service_name" {
  description = "The Harness service Name."
}

variable "artifactsource_name" {
  description = "The Harness ArtifactSource Name."
}

variable "resource_type" {
  description = "The type of resource to execute. Valid options are `workflow` and `pipeline`."
}

variable "resource_name" {
  description = "The name of the resource to execute."
}

variable "environment_name" {
  description = "The name of the environment to target." 
}

variable "infrastructure_definition_name" {
  description = "The name of the infrastructure definition to target."
}
