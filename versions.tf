terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=3.0.2"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.12.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.4.3"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
  }
  required_version = ">= 1.2.5"
}
