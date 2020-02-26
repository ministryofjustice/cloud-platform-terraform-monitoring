##########
# THANOS #
##########

# This is to create a policy which allows Prometheus (thanos to be precise) to have a role to write to S3 without credentials
data "aws_iam_policy_document" "monitoring_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [ var.iam_role_nodes ]
    }
  }
}

resource "aws_iam_role" "monitoring" {
  name               = "monitoring.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume.json
}

data "aws_iam_policy_document" "monitoring" {

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject"
    ]

    # Bucket name is hardcoded because it hasn't been created with terraform
    # files inside this repository. Once we are happy with the test we must: 
    # 1. Create S3 bucket from the cp-environments repo (or maybe from here?)
    # 2. Use the output (S3 bucket name) in this policy
    resources = [
      "arn:aws:s3:::cloud-platform-prometheus-thanos/*",
      "arn:aws:s3:::cloud-platform-prometheus-thanos"
    ]
  }
}

resource "aws_iam_role_policy" "monitoring" {
  name   = "route53"
  role   = aws_iam_role.monitoring.id
  policy = data.aws_iam_policy_document.monitoring.json
}

# Thanos side-car service (not deployment needed because prometheus-operator included it)
resource "kubernetes_service" "thanos_sidecar" {
  metadata {
    name      = "thanos-sidecar"
    namespace = kubernetes_namespace.monitoring.id
    labels = {
      app = "thanos-sidecar"
    }
  }
  spec {
    selector = {
      app = "prometheus"
    }
    port {
      name        = "grpc"
      port        = 10901
      target_port = "grpc"
    }
  }
}

# Thanos Query deployment
resource "kubernetes_deployment" "thanos_query" {
  metadata {
    name      = "thanos-query"
    namespace = kubernetes_namespace.monitoring.id
    labels = {
      app = "thanos-query"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "thanos-query"
      }
    }

    template {
      metadata {
        labels = {
          app = "thanos-query"
        }
      }

      spec {
        container {
          image = "quay.io/thanos/thanos:v0.10.1"
          name  = "thanos-query"

          args = [
            "query",
            "--log.level=debug",
            "--query.replica-label=prometheus_replica",
            "--query.replica-label=thanos_ruler_replica",
            "--store=dnssrv+_grpc._tcp.thanos-sidecar.${kubernetes_namespace.monitoring.id}.svc.cluster.local",
            "--store=dnssrv+_grpc._tcp.thanos-ruler.${kubernetes_namespace.monitoring.id}.svc.cluster.local"
          ]

          port {
            name           = "http"
            container_port = 10902
          }

          port {
            name           = "grpc"
            container_port = 10901
          }


        }
      }
    }
  }
}

# Thanos side-car service (not deployment needed because prometheus-operator included it)
resource "kubernetes_service" "thanos_query" {
  metadata {
    name      = "thanos-query"
    namespace = kubernetes_namespace.monitoring.id
    labels = {
      app = "thanos-query"
    }
  }
  spec {
    selector = {
      app = "thanos-query"
    }
    port {
      name        = "http"
      port        = 9090
      target_port = "http"
    }
  }
}


