
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  version    = "5.11.0"

  lifecycle {
    ignore_changes = [keyring]
  }

  set {
    name  = "extraArgs.kubelet-insecure-tls"
    value = "true"
  }

  set {
    name  = "extraArgs.kubelet-preferred-address-types"
    value = "InternalIP"
  }

  set {
    name  = "hostNetwork"
    value = "true"
  }

}
