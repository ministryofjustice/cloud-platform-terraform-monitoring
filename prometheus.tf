# Grafana secrets
resource "kubernetes_secret" "grafana_secret" {
  metadata {
    name      = "grafana-env"
    namespace = kubernetes_namespace.monitoring.id
  }

  data = {
    GF_AUTH_GENERIC_OAUTH_CLIENT_ID     = var.oidc_components_client_id
    GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = var.oidc_components_client_secret
    GF_AUTH_GENERIC_OAUTH_AUTH_URL      = "${var.oidc_issuer_url}authorize"
    GF_AUTH_GENERIC_OAUTH_TOKEN_URL     = "${var.oidc_issuer_url}oauth/token"
    GF_AUTH_GENERIC_OAUTH_API_URL       = "${var.oidc_issuer_url}userinfo"
  }

  type = "Opaque"
}

resource "random_id" "username" {
  byte_length = 8
}

resource "random_id" "password" {
  byte_length = 8
}

# NOTE: Make sure to update the correct CRD version(if required) using the terraform resource in core
# `kubectl_manifest.prometheus_operator_crds` before upgrading prometheus operator
resource "helm_release" "prometheus_operator_eks" {

  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.id
  version    = "66.2.1"
  skip_crds  = true # Crds are managed separately using resource kubectl_manifest.prometheus_operator_crds in core
  timeout    = 600

  values = [templatefile("${path.module}/templates/prometheus-operator-eks.yaml.tpl", {
    alertmanager_ingress                       = local.alertmanager_ingress
    grafana_ingress                            = local.grafana_ingress
    pagerduty_config                           = var.pagerduty_config
    alertmanager_routes                        = join("\n", local.alertmanager_routes)
    alertmanager_receivers                     = join("\n", local.alertmanager_receivers)
    prometheus_ingress                         = local.prometheus_ingress
    grafana_assumerolearn                      = aws_iam_role.grafana_role.arn
    clusterName                                = terraform.workspace
    enable_prometheus_affinity_and_tolerations = var.enable_prometheus_affinity_and_tolerations
    enable_thanos_sidecar                      = var.enable_thanos_sidecar
    enable_large_nodesgroup                    = var.enable_large_nodesgroup
    large_nodesgroup_cpu_requests              = var.large_nodesgroup_cpu_requests
    large_nodesgroup_memory_requests           = var.large_nodesgroup_memory_requests
    prometheus_sa_name                         = local.prometheus_sa_name
    eks_service_account                        = module.iam_assumable_role_monitoring.iam_role_arn
    storage_class                              = can(regex("live", terraform.workspace)) ? "io1-expand" : "gp2-expand"
    storage_size                               = can(regex("live", terraform.workspace)) ? "750Gi" : "75Gi"
  })]

  set_sensitive {
    name  = "grafana.env.GF_SERVER_ROOT_URL"
    value = local.grafana_root
  }

  set_sensitive {
    name  = "grafana.adminUser"
    value = random_id.username.hex
  }

  set_sensitive {
    name  = "grafana.adminPassword"
    value = random_id.password.hex
  }

  # Depends on Helm being installed
  depends_on = [
    kubernetes_secret.grafana_secret,
    kubernetes_secret.thanos_config,
    kubernetes_secret.dockerhub_credentials
  ]

  # Delete Prometheus leftovers
  # Ref: https://github.com/coreos/prometheus-operator#removal
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete svc -l k8s-app=kubelet -n kube-system"
  }

  lifecycle {
    ignore_changes = [keyring]
  }
}

# apply prometheusrule alerts
resource "kubectl_manifest" "prometheusrule_alerts" {
  for_each = fileset("${path.module}/resources/prometheusrule-alerts", "*.yaml")

  yaml_body          = templatefile("${path.module}/resources/prometheusrule-alerts/${each.value}", {})
  override_namespace = "monitoring"
  wait_for_rollout   = true

  depends_on = [helm_release.prometheus_operator_eks]
}

# apply manager only alerts when the manager alerts are updated
resource "kubectl_manifest" "manager_only_alerts" {
  count = terraform.workspace == "manager" ? 1 : 0

  yaml_body          = file("${path.module}/resources/manager_only_alerts.yaml")
  override_namespace = "monitoring"
  wait               = true

  depends_on = [helm_release.prometheus_operator_eks]
}

# Alertmanager and Prometheus proxy
# Ref: https://github.com/evry/docker-oidc-proxy
resource "random_id" "session_secret" {
  byte_length = 16
}

# This Ingress is to re-direct "grafana.cloud-platform.service.justice.gov.uk" to grafana_root URL
# GF_SERVER_ROOT_URL supports only one URL, so cannot create multiple hosts as Prometheus and alertmanager in this module.

resource "kubernetes_ingress_v1" "ingress_redirect_grafana" {
  count = local.ingress_redirect ? 1 : 0
  metadata {
    name      = "ingress-redirect-grafana"
    namespace = kubernetes_namespace.monitoring.id
    annotations = {
      "external-dns.alpha.kubernetes.io/aws-weight"     = "100"
      "external-dns.alpha.kubernetes.io/set-identifier" = "dns-grafana"
      "cloud-platform.justice.gov.uk/ignore-external-dns-weight" : "true"
      "nginx.ingress.kubernetes.io/permanent-redirect" = local.grafana_root
    }
  }
  spec {
    ingress_class_name = "default"
    tls {
      hosts = ["grafana.${local.live_domain}"]
    }
    rule {
      host = "grafana.${local.live_domain}"
      http {
        path {
          path = ""
          backend {
            service {
              name = "prometheus-operator-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
