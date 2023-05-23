terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "~> 0.2.7"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 0.14.0"
    }
  }
}
