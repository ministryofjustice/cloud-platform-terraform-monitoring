# cloud-platform-terraform-monitoring

Terraform module that deploy cloud-platform monitoring solution. It has support for components like: proxy, thanos, cloudwatch datasource for grafana, side-car, etc

## Usage

```hcl
module "monitoring" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-monitoring?ref=0.1.3"

  alertmanager_slack_receivers               = var.alertmanager_slack_receivers
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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=4.24.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.6.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >=3.2.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 2.1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.12.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.4.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=4.24.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.6.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 2.1.3 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >=2.12.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_assumable_role_monitoring"></a> [iam\_assumable\_role\_monitoring](#module\_iam\_assumable\_role\_monitoring) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.52.1 |
| <a name="module_iam_assumable_role_yace_cloudwatch_exporter"></a> [iam\_assumable\_role\_yace\_cloudwatch\_exporter](#module\_iam\_assumable\_role\_yace\_cloudwatch\_exporter) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 5.52.1 |
| <a name="module_irsa"></a> [irsa](#module\_irsa) | github.com/ministryofjustice/cloud-platform-terraform-irsa | 2.0.0 |
| <a name="module_rds_exporter_irsa"></a> [rds\_exporter\_irsa](#module\_rds\_exporter\_irsa) | github.com/ministryofjustice/cloud-platform-terraform-irsa | 2.0.0 |
| <a name="module_subnet_exporter_irsa"></a> [subnet\_exporter\_irsa](#module\_subnet\_exporter\_irsa) | github.com/ministryofjustice/cloud-platform-terraform-irsa | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ecr_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.grafana_datasource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.subnet_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.yace_cloudwatch_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.grafana_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.alertmanager_proxy](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ecr_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_operator_eks](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.prometheus_proxy](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.rds_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.subnet_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.thanos](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.thanos_proxy](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.yace_cloudwatch_exporter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.manager_only_alerts](https://registry.terraform.io/providers/alekc/kubectl/2.1.3/docs/resources/manifest) | resource |
| [kubectl_manifest.prometheusrule_alerts](https://registry.terraform.io/providers/alekc/kubectl/2.1.3/docs/resources/manifest) | resource |
| [kubernetes_ingress_v1.ingress_redirect_grafana](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_limit_range.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range) | resource |
| [kubernetes_namespace.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.allow-monitoring-alerts](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.allow_ingress_controllers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.allow_kube_api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_resource_quota.monitoring](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/resource_quota) | resource |
| [kubernetes_secret.dockerhub_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.grafana_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret.thanos_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_id.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.session_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.username](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role_with_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.grafana_datasource_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.rds_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.subnet_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.yace_cloudwatch_exporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager_slack_receivers"></a> [alertmanager\_slack\_receivers](#input\_alertmanager\_slack\_receivers) | A list of configuration values for Slack receivers | `list(any)` | n/a | yes |
| <a name="input_application"></a> [application](#input\_application) | n/a | `string` | `"Monitoring"` | no |
| <a name="input_aws_subnet_exporter_image_tag"></a> [aws\_subnet\_exporter\_image\_tag](#input\_aws\_subnet\_exporter\_image\_tag) | Tag of the subnet exporter image to use | `string` | `""` | no |
| <a name="input_business_unit"></a> [business\_unit](#input\_business\_unit) | n/a | `string` | `"Platforms"` | no |
| <a name="input_cluster_domain_name"></a> [cluster\_domain\_name](#input\_cluster\_domain\_name) | The cluster domain - used by externalDNS and certmanager to create URLs | `any` | n/a | yes |
| <a name="input_dockerhub_password"></a> [dockerhub\_password](#input\_dockerhub\_password) | DockerHub password - required to avoid hitting Dockerhub API limits in EKS clusters | `string` | `""` | no |
| <a name="input_dockerhub_username"></a> [dockerhub\_username](#input\_dockerhub\_username) | DockerHub username - required to avoid hitting Dockerhub API limits in EKS clusters | `string` | `""` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | n/a | `string` | `"live"` | no |
| <a name="input_eks_cluster_oidc_issuer_url"></a> [eks\_cluster\_oidc\_issuer\_url](#input\_eks\_cluster\_oidc\_issuer\_url) | This is going to be used when we create the IAM OIDC role | `string` | `""` | no |
| <a name="input_enable_cloudwatch_exporter"></a> [enable\_cloudwatch\_exporter](#input\_enable\_cloudwatch\_exporter) | Enable or not Cloudwatch exporter | `bool` | `false` | no |
| <a name="input_enable_ecr_exporter"></a> [enable\_ecr\_exporter](#input\_enable\_ecr\_exporter) | Enable or not ECR exporter | `bool` | `false` | no |
| <a name="input_enable_large_nodesgroup"></a> [enable\_large\_nodesgroup](#input\_enable\_large\_nodesgroup) | Due to Prometheus resource consumption, enabling this will set k8s Prometheus resources to higher values | `bool` | `false` | no |
| <a name="input_enable_prometheus_affinity_and_tolerations"></a> [enable\_prometheus\_affinity\_and\_tolerations](#input\_enable\_prometheus\_affinity\_and\_tolerations) | Enable or not Prometheus node affinity (check helm values for the expressions) | `bool` | `false` | no |
| <a name="input_enable_rds_exporter"></a> [enable\_rds\_exporter](#input\_enable\_rds\_exporter) | Whether or not to enable the RDS exporter | `bool` | `false` | no |
| <a name="input_enable_subnet_exporter"></a> [enable\_subnet\_exporter](#input\_enable\_subnet\_exporter) | Whether or not to enable the Subnet exporter | `bool` | `false` | no |
| <a name="input_enable_thanos_compact"></a> [enable\_thanos\_compact](#input\_enable\_thanos\_compact) | Enable or not Thanos Compact - not semantically concurrency safe and must be deployed as a singleton against a bucket | `bool` | `false` | no |
| <a name="input_enable_thanos_helm_chart"></a> [enable\_thanos\_helm\_chart](#input\_enable\_thanos\_helm\_chart) | Enable or not Thanos Helm Chart - (do NOT confuse this with thanos sidecar within prometheus-operator) | `bool` | `false` | no |
| <a name="input_enable_thanos_sidecar"></a> [enable\_thanos\_sidecar](#input\_enable\_thanos\_sidecar) | Enable or not Thanos sidecar. Basically defines if we want to send cluster metrics to thanos's S3 bucket | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"production"` | no |
| <a name="input_infrastructure_support"></a> [infrastructure\_support](#input\_infrastructure\_support) | n/a | `string` | `"Cloud Platform"` | no |
| <a name="input_is_production"></a> [is\_production](#input\_is\_production) | n/a | `string` | `"true"` | no |
| <a name="input_large_nodesgroup_cpu_requests"></a> [large\_nodesgroup\_cpu\_requests](#input\_large\_nodesgroup\_cpu\_requests) | CPU requests for large nodesgroup | `string` | `"1300m"` | no |
| <a name="input_large_nodesgroup_memory_requests"></a> [large\_nodesgroup\_memory\_requests](#input\_large\_nodesgroup\_memory\_requests) | Memory requests for large nodesgroup | `string` | `"14000Mi"` | no |
| <a name="input_oidc_components_client_id"></a> [oidc\_components\_client\_id](#input\_oidc\_components\_client\_id) | OIDC ClientID used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | `any` | n/a | yes |
| <a name="input_oidc_components_client_secret"></a> [oidc\_components\_client\_secret](#input\_oidc\_components\_client\_secret) | OIDC ClientSecret used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | `any` | n/a | yes |
| <a name="input_oidc_issuer_url"></a> [oidc\_issuer\_url](#input\_oidc\_issuer\_url) | Issuer URL used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy) | `any` | n/a | yes |
| <a name="input_pagerduty_config"></a> [pagerduty\_config](#input\_pagerduty\_config) | Add PagerDuty key to allow integration with a PD service. | `any` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | n/a | `string` | `"webops"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_prometheus_operator_eks_status"></a> [helm\_prometheus\_operator\_eks\_status](#output\_helm\_prometheus\_operator\_eks\_status) | n/a |
<!-- END_TF_DOCS -->