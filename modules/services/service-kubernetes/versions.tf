terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.20.0"
    }
    utils = {
      source  = "cloudposse/utils"
      version = ">= 0.14.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.3"
    }
  }
}