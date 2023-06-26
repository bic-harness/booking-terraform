terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.20.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
  }
}