provider "aws" {
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "eu-west-2"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

module "opa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-opa"

  cluster_domain_name = "prometheus.cloud-platform.service.justice.gov.uk"
}

module "prometheus" {
  source = "../../"

  alertmanager_slack_receivers = [
    {
      severity = "warning"
      webhook  = "https://hooks.slack.com/services/XXXXX/XXXX/XXXXX"
      channel  = "#lower-priority-alarms"
  }]

  iam_role_nodes                             = "arn:mogaal"
  pagerduty_config                           = "asdasd"
  enable_ecr_exporter                        = false
  enable_cloudwatch_exporter                 = false
  enable_thanos_helm_chart                   = false
  enable_thanos_sidecar                      = false
  enable_prometheus_affinity_and_tolerations = false

  cluster_domain_name           = "prometheus.cloud-platform.service.justice.gov.uk"
  oidc_components_client_id     = "XXX"
  oidc_components_client_secret = "XXX"
  oidc_issuer_url               = "https://justice-cloud-platform.eu.auth0.com/"

  dependence_opa = module.opa.helm_opa_status
}
