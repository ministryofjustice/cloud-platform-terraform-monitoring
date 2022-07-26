terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
  required_version = ">= 0.14"
}
