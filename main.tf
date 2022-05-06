
#############
# Namespace #
#############

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      "component" = "monitoring"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"                = "Monitoring"
      "cloud-platform.justice.gov.uk/business-unit"              = "Platforms"
      "cloud-platform.justice.gov.uk/owner"                      = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"                = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
      "iam.amazonaws.com/permitted"                              = ".*"
      "cloud-platform.justice.gov.uk/can-tolerate-master-taints" = "true"
      "cloud-platform-out-of-hours-alert"                        = "true"
    }
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

##################
# DockerHub auth #
##################

resource "kubernetes_secret" "dockerhub_credentials" {

  metadata {
    name      = "dockerhub-credentials"
    namespace = kubernetes_namespace.monitoring.id
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "https://index.docker.io/v1": {
      "auth": "${base64encode("${var.dockerhub_username}:${var.dockerhub_password}")}"
    }
  }
}
DOCKER
  }
}

##############
# LimitRange #
##############

resource "kubernetes_limit_range" "monitoring" {
  metadata {
    name      = "limitrange"
    namespace = kubernetes_namespace.monitoring.id
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "1600m"
        memory = "24Gi"
      }
      default_request = {
        cpu    = "10m"
        memory = "100Mi"
      }
    }
  }
}

###################
# Resource Quotas #
###################

resource "kubernetes_resource_quota" "monitoring" {
  metadata {
    name      = "namespace-quota"
    namespace = kubernetes_namespace.monitoring.id
  }
  spec {
    hard = {
      pods = 100
    }
  }
}

####################
# Network Policies #
####################

resource "kubernetes_network_policy" "default" {
  metadata {
    name      = "default"
    namespace = kubernetes_namespace.monitoring.id
  }

  spec {
    pod_selector {}
    ingress {
      from {
        pod_selector {}
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_ingress_controllers" {
  metadata {
    name      = "allow-ingress-controllers"
    namespace = kubernetes_namespace.monitoring.id
  }

  spec {
    pod_selector {}
    ingress {
      from {
        namespace_selector {
          match_labels = {
            component = "ingress-controllers"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_kube_api" {
  metadata {
    name      = "allow-kube-api"
    namespace = kubernetes_namespace.monitoring.id
  }

  spec {
    pod_selector {}
    ingress {
      from {
        namespace_selector {
          match_labels = {
            component = "kube-system"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_alertmanager_api" {
  metadata {
    name      = "allow-alertmanager-api"
    namespace = kubernetes_namespace.monitoring.id
  }

  spec {
    pod_selector {
      match_labels = {
        app = "alertmanager"
      }
    }
    ingress {
      from {
        namespace_selector {}
      }
    }

    policy_types = ["Ingress"]
  }
}

