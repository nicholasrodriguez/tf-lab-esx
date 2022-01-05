terraform {
  required_version = ">= 0.14"
  required_providers {
    esxi = {
      source  = "registry.terraform.io/josenk/esxi"
      version = ">=1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}
