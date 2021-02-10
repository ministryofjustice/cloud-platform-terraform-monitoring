# cloud-platform-terraform-monitoring

Terraform module that deploy cloud-platform monitoring solution. It has support for components like: proxy, thanos, cloudwatch datasource for grafana, side-car, etc

## Usage

```hcl
module "monitoring" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-monitoring?ref=0.1.3"

  alertmanager_slack_receivers               = var.alertmanager_slack_receivers
  iam_role_nodes                             = data.aws_iam_role.nodes.arn
  pagerduty_config                           = var.pagerduty_config
  enable_ecr_exporter                        = terraform.workspace == local.live_workspace ? true : false
  enable_cloudwatch_exporter                 = terraform.workspace == local.live_workspace ? true : false
  enable_thanos_helm_chart                   = terraform.workspace == local.live_workspace ? true : false
  enable_prometheus_affinity_and_tolerations = terraform.workspace == local.live_workspace ? true : false
  
  cluster_domain_name           = data.terraform_remote_state.cluster.outputs.cluster_domain_name
  oidc_components_client_id     = data.terraform_remote_state.cluster.outputs.oidc_components_client_id
  oidc_components_client_secret = data.terraform_remote_state.cluster.outputs.oidc_components_client_secret
  oidc_issuer_url               = data.terraform_remote_state.cluster.outputs.oidc_issuer_url

  dependence_opa    = module.opa.helm_opa_status
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
| dependence_opa               | The key_pair name to be used in the bastion instance    | string | | yes |
| cluster_domain_name          | Value used by externalDNS and certmanager               | string | | yes |
| oidc_components_client_id    | OIDC ClientID used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | string | | yes |
| oidc_components_client_secret | OIDC ClientSecret used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | string | | yes |
| oidc_issuer_url              | Issuer URL used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | string | | yes |
| eks                          | Are we deploying in EKS or not?                                                       | bool     | false   | no |
| eks_cluster_oidc_issuer_url  | The OIDC issuer URL from the cluster, it is used for IAM ServiceAccount integration   | string     |  | no |

## Outputs

| Name | Description |
|------|-------------|
| helm_prometheus_operator_status | This is an output used as a dependency (to know the prometheus-operator chart has been deployed) |
