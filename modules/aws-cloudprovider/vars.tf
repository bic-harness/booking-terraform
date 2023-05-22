variable "technology_area" {
  description = "The UAL Technology Area."
  type = string
}

variable "app_ci" {
  description = "The UAL AppCI."
  type = string 
}

variable "tier" {
  description = "The application tier. Valid values are `nonprod` and `prod`."
  default = "nonprod"
  type = string
  
  validation {
    condition     = can(regex("(nonprod|prod)", var.tier))
    error_message = "Invalid tier. Valid values are `nonprod` and `prod`."
  }
}

variable "aws_account_id" {
  description = "The AWS account ID."
  type = string
}

variable "irsa_enabled" {
  description = "Specify whether or not to use a role assigned to the delegate using IRSA."
  default = false
}

variable "delegate_selector" {
  description = "Select the delegate to use via one of its selectors."
  default = ""
}

variable "cross_account_role_name" {
  description = "The name of the role to assume."
  default = "HarnessCDDelegateRole"
}

variable "cross_account_role_external_id" {
  description = "If the administrator of the account to which the role belongs provided you with an external ID, then enter that value."
  default = ""
}
