
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://charts.helm.sh/stable"
  namespace  = "kube-system"
  version    = "2.8.8"

  lifecycle {
    ignore_changes = [keyring]
  }

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  set {
    name  = "hostNetwork.enabled"
    value = "true"
  }

}
