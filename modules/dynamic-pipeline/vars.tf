variable "technology_area" {
  description = "The UAL Technology Area."
}

variable "app_ci" {
  description = "The UAL AppCI."
}

variable "release_id" {
  description = "A unique identifier for the release."
}

variable "infradef" {
  default = "The name of the infrastructure definition to use."
}

variable "environment" {
  default = "The name of the environment to deploy to."
}

variable "workflow_name" {
  description = "The name of the workflow to use for each stage of the deployment."
}

variable "bom" {
  description = "The bill of materials. A JSON map of key/value pairs represnting the name  of the service and the version to deploy."
  type        = map(string)
}
