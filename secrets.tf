module "secret_manager" {
  count = terraform.workspace == "live" ? 1 : 0
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=2.0.0"

  team_name              = "webops"
  application            = "elasticsearch"
  business_unit          = "Platforms"
  is_production          = "true"
  namespace              = "monitoring"
  environment            = "production"
  infrastructure_support = "cloud-platform"
  eks_cluster_name       = terraform.workspace

  secrets = {
    "slack_webhook_url" = {
      description             = "url used for kibana to post alerts to a channel", // Required
      recovery_window_in_days = 0,                                                 // Required
      k8s_secret_name         = "slack_webhook_url"                                // The name of the secret in k8s
    },
  }
}

data "aws_secretsmanager_secret" "slack_webhook_url" {
  name = module.secret_manager.secrets["slack_webhook_url"].name
}

data "aws_secretsmanager_secret_version" "slack_webhook_url" {
  secret_id = data.aws_secretsmanager_secret.slack_webhook_url.id
}