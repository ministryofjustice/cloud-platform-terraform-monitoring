
locals {
  live_workspace   = "live"
  live_domain      = "cloud-platform.service.justice.gov.uk"
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
  prometheus_dependency               = helm_release.prometheus_operator_eks
  prometheus_operator_crds_dependency = kubectl_manifest.prometheus_operator_crds

  prometheus_crd_yamls = {
    alertmanager_configs = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml"
    alertmanagers        = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml"
    podmonitors          = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml"
    probes               = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml"
    prometheusagents     = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml"
    prometheuses         = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml"
    prometheusrules      = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml"
    scrapeconfigs        = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml"
    servicemonitors      = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"
    thanosrulers         = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/${var.prometheus_operator_crd_version}/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml"
  }
  
  ecr_exporter_sa = "ecr-exporter"
}