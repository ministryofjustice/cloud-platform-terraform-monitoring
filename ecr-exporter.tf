

################
# ECR Exporter #
################

resource "helm_release" "ecr_exporter" {
  count = var.enable_ecr_exporter ? 1 : 0

  name       = "ecr-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  chart      = "prometheus-ecr-exporter"
  repository = data.helm_repository.cloud_platform.metadata[0].name

  set {
    name  = "serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "aws.role"
    value = aws_iam_role.ecr_exporter.name
  }

  set {
    name  = "aws.region"
    value = "eu-west-2"
  }

  depends_on = [
    var.dependence_deploy,
    helm_release.prometheus_operator,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

