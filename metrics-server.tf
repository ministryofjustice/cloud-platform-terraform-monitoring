
resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  namespace  = "kube-system"
  version    = "5.10.14"

  lifecycle {
    ignore_changes = [keyring]
  }

  set {
    name  = "extraArgs[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "extraArgs[1]"
    value = "--kubelet-preferred-address-types=InternalIP"
  }

  set {
    name  = "hostNetwork"
    value = "true"
  }

}
