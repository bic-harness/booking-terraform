terraform {
  required_providers {
    
    harness = {
      source  = "harness/harness"
      version = "~> 0.2.7"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0"
    }

  }
}
