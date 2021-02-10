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

data "template_file" "alertmanager_routes" {
  count = length(var.alertmanager_slack_receivers)

  template = <<EOS
- match:
    severity: info-$${severity}
  receiver: slack-info-$${severity}
  continue: true
- match:
    severity: $${severity}
  receiver: slack-$${severity}
EOS


  vars = var.alertmanager_slack_receivers[count.index]
}

data "template_file" "alertmanager_receivers" {
  count = length(var.alertmanager_slack_receivers)

  template = <<EOS
- name: 'slack-$${severity}'
  slack_configs:
  - api_url: "$${webhook}"
    channel: "$${channel}"
    send_resolved: True
    title: '{{ template "slack.cp.title" . }}'
    text: '{{ template "slack.cp.text" . }}'
    footer: ${local.alertmanager_ingress}
    actions:
    - type: button
      text: 'Runbook :blue_book:'
      url: '{{ (index .Alerts 0).Annotations.runbook_url }}'
    - type: button
      text: 'Query :mag:'
      url: '{{ (index .Alerts 0).GeneratorURL }}'
    - type: button
      text: 'Silence :no_bell:'
      url: '{{ template "__alert_silence_link" . }}'
- name: 'slack-info-$${severity}'
  slack_configs:
  - api_url: "$${webhook}"
    channel: "$${channel}"
    send_resolved: False
    title: '{{ template "slack.cp.title" . }}'
    text: '{{ template "slack.cp.text" . }}'
    color: 'good'
    footer: ${local.alertmanager_ingress}
    actions:
    - type: button
      text: 'Query :mag:'
      url: '{{ (index .Alerts 0).GeneratorURL }}'
EOS


  vars = var.alertmanager_slack_receivers[count.index]
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.id
  version    = "12.12.0"

  values = [templatefile("${path.module}/templates/prometheus-operator.yaml.tpl", {
    alertmanager_ingress                       = local.alertmanager_ingress
    grafana_ingress                            = local.grafana_ingress
    grafana_root                               = local.grafana_root
    pagerduty_config                           = var.pagerduty_config
    alertmanager_routes                        = "${join("", data.template_file.alertmanager_routes.*.rendered)}"
    alertmanager_receivers                     = "${join("", data.template_file.alertmanager_receivers.*.rendered)}"
    prometheus_ingress                         = local.prometheus_ingress
    random_username                            = random_id.username.hex
    random_password                            = random_id.password.hex
    grafana_pod_annotation                     = var.eks ? "module.iam_assumable_role_grafana_datasource.this_iam_role_name" : aws_iam_role.grafana_datasource.0.name
    grafana_assumerolearn                      = var.eks ? "module.iam_assumable_role_grafana_datasource.this_iam_role_arn" : aws_iam_role.grafana_datasource.0.arn
    monitoring_aws_role                        = var.eks ? module.iam_assumable_role_monitoring.this_iam_role_name : aws_iam_role.monitoring.0.name
    clusterName                                = terraform.workspace
    enable_prometheus_affinity_and_tolerations = var.enable_prometheus_affinity_and_tolerations
    storage_class                              = var.eks ? "gp2" : "io1-expand"
    enable_thanos_sidecar                      = var.enable_thanos_sidecar

    # This is for EKS
    eks                 = var.eks
    eks_service_account = module.iam_assumable_role_monitoring.this_iam_role_arn
  })]

  # Depends on Helm being installed
  depends_on = [
    var.dependence_opa,
    kubernetes_secret.grafana_secret,
    kubernetes_secret.thanos_config,
    kubernetes_secret.dockerhub_credentials
  ]

  provisioner "local-exec" {
    command = "kubectl apply -n monitoring -f ${path.module}/resources/prometheusrule-alerts/"
  }

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

# Alertmanager and Prometheus proxy
# Ref: https://github.com/evry/docker-oidc-proxy
resource "random_id" "session_secret" {
  byte_length = 16
}

data "template_file" "prometheus_proxy" {
  template = file("${path.module}/templates/oauth2-proxy.yaml.tpl")

  vars = {
    upstream = "http://prometheus-operator-kube-p-prometheus:9090"
    hostname = terraform.workspace == local.live_workspace ? format("%s.%s", "prometheus", local.live_domain) : format(
      "%s.%s",
      "prometheus.apps",
      var.cluster_domain_name,
    )
    exclude_paths = "^/-/healthy$"
    issuer_url    = var.oidc_issuer_url
    client_id     = var.oidc_components_client_id
    client_secret = var.oidc_components_client_secret
    cookie_secret = random_id.session_secret.b64_std
    eks           = var.eks
  }
}

resource "helm_release" "prometheus_proxy" {
  name       = "prometheus-proxy"
  namespace  = kubernetes_namespace.monitoring.id
  repository = "https://charts.helm.sh/stable"
  chart      = "oauth2-proxy"
  version    = "3.2.2"

  values = [
    data.template_file.prometheus_proxy.rendered,
  ]

  depends_on = [
    var.dependence_opa,
    random_id.session_secret,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

data "template_file" "alertmanager_proxy" {
  template = file("${path.module}/templates/oauth2-proxy.yaml.tpl")

  vars = {
    upstream = "http://prometheus-operator-kube-p-alertmanager:9093"
    hostname = terraform.workspace == local.live_workspace ? format("%s.%s", "alertmanager", local.live_domain) : format(
      "%s.%s",
      "alertmanager.apps",
      var.cluster_domain_name,
    )
    exclude_paths = "^/-/healthy$"
    issuer_url    = var.oidc_issuer_url
    client_id     = var.oidc_components_client_id
    client_secret = var.oidc_components_client_secret
    cookie_secret = random_id.session_secret.b64_std
    eks           = var.eks
  }
}

resource "helm_release" "alertmanager_proxy" {
  name       = "alertmanager-proxy"
  namespace  = "monitoring"
  repository = "https://charts.helm.sh/stable"
  chart      = "oauth2-proxy"
  version    = "3.2.2"

  values = [
    data.template_file.alertmanager_proxy.rendered,
  ]

  depends_on = [
    var.dependence_opa,
    random_id.session_secret,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

######################
# Grafana Cloudwatch #
######################

# Grafana datasource for cloudwatch
# Ref: https://github.com/helm/charts/blob/master/stable/grafana/values.yaml

data "aws_iam_policy_document" "grafana_datasource_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "grafana_datasource" {
  count = var.eks ? 0 : 1

  name               = "datasource.${var.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.grafana_datasource_assume.json
}

# Minimal policy permissions 
# Ref: https://grafana.com/docs/grafana/latest/features/datasources/cloudwatch/#iam-policies

data "aws_iam_policy_document" "grafana_datasource" {
  count = var.eks ? 0 : 1

  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.grafana_datasource.0.arn]
  }
}

resource "aws_iam_role_policy" "grafana_datasource" {
  count = var.eks ? 0 : 1

  name   = "grafana-datasource"
  role   = aws_iam_role.grafana_datasource.0.id
  policy = data.aws_iam_policy_document.grafana_datasource.0.json
}
