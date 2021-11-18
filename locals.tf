
locals {
  live_workspace = "live-1"
  live_domain    = "cloud-platform.service.justice.gov.uk"
  ingress_redirect = terraform.workspace == local.live_workspace ? true : false

  alertmanager_ingress = format(
    "%s.%s",
    "https://alertmanager",
    var.cluster_domain_name,
  )
  grafana_ingress = format(
    "%s.%s",
    "grafana",
    var.cluster_domain_name,
  )
  grafana_root = format(
    "%s.%s",
    "https://grafana",
    var.cluster_domain_name,
  )
  prometheus_ingress = format(
    "%s.%s",
    "https://prometheus",
    var.cluster_domain_name,
  )
  prometheus_dependency = var.eks ? helm_release.prometheus_operator_eks : helm_release.prometheus_operator
}