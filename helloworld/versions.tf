terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.20."
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.3"
    }
  }
}
