# cloud-platform-terraform-prometheus

Terraform module that deploy cloud-platform monitoring solution. It has support for components like: proxy, thanos, cloudwatch datasource for grafana, side-car, etc

## Usage

```hcl
module "prometheus" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-prometheus?ref=0.0.1"

  alertmanager_slack_receivers = var.alertmanager_slack_receivers
  iam_role_nodes               = data.aws_iam_role.nodes.arn
  pagerduty_config             = var.pagerduty_config
  enable_thanos                = true

  # This module requires helm and OPA already deployed
  dependence_deploy = null_resource.deploy
  dependence_opa    = helm_release.open-policy-agent
}
```

## Inputs

| Name                         | Description         | Type | Default | Required |
|------------------------------|---------------------|:----:|:-------:|:--------:|
| alertmanager_slack_receivers | A list of configuration values for Slack receivers      | string |  | yes |
| iam_role_nodes               | Nodes IAM role ARN in order to create the KIAM/Kube2IAM | string | | yes |
| pagerduty_config             | PagerDuty key to allow integration with a PD service    | string | | yes |
| enable_thanos                | Enable or not Thanos                                    | bool   | false | no |
| enable_ecr_exporter          | Conditional to deploy ECR Exporter                      | bool   | false | no |
| enable_cloudwatch_exporter   | Conditional to deploy CloudWatch Exporter               | bool   | false | no |
| dependence_deploy            | Dependency on helm                                      | string | | yes |
| dependence_opa               | The key_pair name to be used in the bastion instance    | string | | yes |

## Outputs

| Name | Description |
|------|-------------|
| helm_prometheus_operator_status | This is an output used as a dependency (to know the prometheus-operator chart has been deployed) |
