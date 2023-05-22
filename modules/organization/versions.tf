terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "~> 0.2.7"
    }
    random = {
      source = "hashicorp/random"
      version = "3.1.3"
    }
  }
}
