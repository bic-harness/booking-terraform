variable "technology_area" {
  description = "The UAL Technology Area."
  type = string
}

variable "app_ci" {
  description = "The UAL AppCI."
  type = string
}

variable "cluster_name" {
  description = "The EKS Cluster to connect to."
  type = string
}

variable "namespace" {
  description = "The namespace to create the Harness service account in."
  default = "harness-delegate"
  type = string
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist."
  default = true
  type = string
}

variable "skip_validation" {
  description = "Wether or not to skip the validation of the cloud provider."
  default = false
  type = bool
}

variable "environment_type" {
  description = "The type of the environment. Valid values are `nonprod` and `prod`."
  default = "nonprod"
  type = string
  
  validation {
    condition     = can(regex("(nonprod|prod)", var.environment_type))
    error_message = "Invalid tier. Valid values are `nonprod` and `prod`."
  }
}
