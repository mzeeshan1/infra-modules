terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.66"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "=2.3.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "=3.2.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "=0.12.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "=4.0.5"
    }
  }
}
