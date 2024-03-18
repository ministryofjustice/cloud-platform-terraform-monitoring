terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.6.0"
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
    template = {
      source  = "hashicorp/template"
      version = ">=2.2.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
  }
  required_version = ">= 1.2.5"
}
