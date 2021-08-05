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

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | n/a |
| random | n/a |
| template | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| iam_assumable_role_cloudwatch_exporter | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.13.0 |
| iam_assumable_role_ecr_exporter | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.13.0 |
| iam_assumable_role_monitoring | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 3.13.0 |

## Resources

| Name |
|------|
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [kubernetes_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress) |
| [kubernetes_limit_range](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range) |
| [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) |
| [kubernetes_network_policy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) |
| [kubernetes_resource_quota](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) |
| [kubernetes_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) |
| [random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) |
| [template_file](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alertmanager\_slack\_receivers | A list of configuration values for Slack receivers | `list` | n/a | yes |
| cluster\_domain\_name | The cluster domain - used by externalDNS and certmanager to create URLs | `any` | n/a | yes |
| dockerhub\_password | DockerHub password - required to avoid hitting Dockerhub API limits in EKS clusters | `string` | `""` | no |
| dockerhub\_username | DockerHub username - required to avoid hitting Dockerhub API limits in EKS clusters | `string` | `""` | no |
| eks | Where are you applying this modules in kOps cluster or in EKS (KIAM or KUBE2IAM?) | `bool` | `false` | no |
| eks\_cluster\_oidc\_issuer\_url | If EKS variable is set to true this is going to be used when we create the IAM OIDC role | `string` | `""` | no |
| enable\_cloudwatch\_exporter | Enable or not Cloudwatch exporter | `bool` | `false` | no |
| enable\_ecr\_exporter | Enable or not ECR exporter | `bool` | `false` | no |
| enable\_kibana\_audit\_proxy | Enable or not Kibana-audit proxy for authentication | `bool` | `false` | no |
| enable\_kibana\_proxy | Enable or not Kibana proxy for authentication | `bool` | `false` | no |
| enable\_large\_nodesgroup | Due to Prometheus resource consumption, enabling this will set k8s Prometheus resources to higher values | `bool` | `false` | no |
| enable\_prometheus\_affinity\_and\_tolerations | Enable or not Prometheus node affinity (check helm values for the expressions) | `bool` | `false` | no |
| enable\_thanos\_compact | Enable or not Thanos Compact - not semantically concurrency safe and must be deployed as a singleton against a bucket | `bool` | `false` | no |
| enable\_thanos\_helm\_chart | Enable or not Thanos Helm Chart - (do NOT confuse this with thanos sidecar within prometheus-operator) | `bool` | `false` | no |
| enable\_thanos\_sidecar | Enable or not Thanos sidecar. Basically defines if we want to send cluster metrics to thanos's S3 bucket | `bool` | `false` | no |
| grafana\_ingress\_redirect\_url | grafana url to use live\_domain, 'cloud-platform.service.justice.gov.uk' | `string` | `""` | no |
| iam\_role\_nodes | Nodes IAM role ARN in order to create the KIAM/Kube2IAM | `string` | n/a | yes |
| ingress\_redirect | Enable ingress\_redirect, to use live\_domain, 'cloud-platform.service.justice.gov.uk' | `bool` | `false` | no |
| oidc\_components\_client\_id | OIDC ClientID used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | `any` | n/a | yes |
| oidc\_components\_client\_secret | OIDC ClientSecret used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | `any` | n/a | yes |
| oidc\_issuer\_url | Issuer URL used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | `any` | n/a | yes |
| pagerduty\_config | Add PagerDuty key to allow integration with a PD service. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| helm\_prometheus\_operator\_status | n/a |

<!--- END_TF_DOCS --->
