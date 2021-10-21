terraform {
  # The required version of the Terraform provider for AWS used by this module.
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>3.55.0"
    }
  }

  # The version range of the Terraform binary which are supported by this module.
  required_version = ">=0.13, <2.0"
}