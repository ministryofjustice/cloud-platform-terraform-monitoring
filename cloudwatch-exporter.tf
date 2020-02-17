# Cloudwatch prometheus exporter
# KIAM role creation
# Ref: https://github.com/helm/charts/blob/master/stable/prometheus-cloudwatch-exporter/values.yaml

resource "helm_release" "cloudwatch_exporter" {
  #count     = terraform.workspace == local.live_workspace ? 1 : 0
  count     = var.enable_cloudwatch_exporter ? 1 : 0



  name      = "cloudwatch-exporter"
  namespace = kubernetes_namespace.monitoring.id
  chart     = "stable/prometheus-cloudwatch-exporter"

  values = [
    file("./resources/cloudwatch-exporter.yaml"),
  ]

  set {
    name  = "aws.role"
    value = aws_iam_role.cloudwatch_exporter.name
  }

  depends_on = [
    var.dependence_deploy,
    helm_release.prometheus_operator,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

