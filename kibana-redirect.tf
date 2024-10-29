resource "kubernetes_ingress_v1" "ingress_redirect_kibana" {
  metadata {
    name      = "ingress-redirect-kibana"
    namespace = kubernetes_namespace.monitoring.id
    annotations = {
      "external-dns.alpha.kubernetes.io/aws-weight"     = "100"
      "external-dns.alpha.kubernetes.io/set-identifier" = "dns-kibana"
      "cloud-platform.justice.gov.uk/ignore-external-dns-weight" : "true"
      "nginx.ingress.kubernetes.io/permanent-redirect" = "https://app-logs.cloud-platform.service.justice.gov.uk/_dashboards"
    }
  }
  spec {
    ingress_class_name = "default"
    tls {
      hosts = ["kibana.cloud-platform.service.justice.gov.uk"]
    }
    rule {
      host = "kibana.cloud-platform.service.justice.gov.uk"
    }
  }
}

