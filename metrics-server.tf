
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [templatefile("${path.module}/templates/metrics-server.yaml.tpl", {
  })]

  depends_on = [
    local.prometheus_dependency,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}
