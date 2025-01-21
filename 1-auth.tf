terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud {
    organization = "MFNERDINCORPORATED"
    workspaces {
      name = "stage2"
    }
  }
}
