provider "aws" {
  region  = "eu-west-2"
  profile = "moj-cp"
}
module "prometheus" {
  source = "../../"

  alertmanager_slack_receivers = [
    {
      severity = "warning"
      webhook  = "https://hooks.slack.com/services/XXXXX/XXXX/XXXXX"
      channel  = "#lower-priority-alarms"
  }]

  pagerduty_config                           = "asdasd"
  enable_ecr_exporter                        = false
  enable_cloudwatch_exporter                 = false
  enable_thanos_helm_chart                   = false
  enable_thanos_sidecar                      = false
  enable_prometheus_affinity_and_tolerations = false
  enable_large_nodesgroup                    = false
  enable_thanos_compact                      = false

  cluster_domain_name           = sensitive("prometheus.cloud-platform.service.justice.gov.uk")
  oidc_components_client_id     = "XXX"
  oidc_components_client_secret = "XXX"
  oidc_issuer_url               = "https://justice-cloud-platform.eu.auth0.com/"
}