variable "alertmanager_slack_receivers" {
  description = "A list of configuration values for Slack receivers"
  type        = list(any)
}

variable "pagerduty_config" {
  description = "Add PagerDuty key to allow integration with a PD service."
}

variable "enable_ecr_exporter" {
  description = "Enable or not ECR exporter"
  default     = false
  type        = bool
}

variable "enable_cloudwatch_exporter" {
  description = "Enable or not Cloudwatch exporter"
  default     = false
  type        = bool
}

variable "enable_thanos_sidecar" {
  description = "Enable or not Thanos sidecar. Basically defines if we want to send cluster metrics to thanos's S3 bucket"
  default     = false
  type        = bool
}

variable "enable_thanos_helm_chart" {
  description = "Enable or not Thanos Helm Chart - (do NOT confuse this with thanos sidecar within prometheus-operator)"
  default     = false
  type        = bool
}

variable "enable_thanos_compact" {
  description = "Enable or not Thanos Compact - not semantically concurrency safe and must be deployed as a singleton against a bucket"
  default     = false
  type        = bool
}

variable "enable_prometheus_affinity_and_tolerations" {
  description = "Enable or not Prometheus node affinity (check helm values for the expressions)"
  default     = false
  type        = bool
}

variable "enable_kibana_audit_proxy" {
  description = "Enable or not Kibana-audit proxy for authentication"
  default     = false
  type        = bool
}

variable "enable_kibana_proxy" {
  description = "Enable or not Kibana proxy for authentication"
  default     = false
  type        = bool
}

variable "cluster_domain_name" {
  description = "The cluster domain - used by externalDNS and certmanager to create URLs"
}

variable "oidc_components_client_id" {
  description = "OIDC ClientID used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy)"
}

variable "oidc_components_client_secret" {
  description = "OIDC ClientSecret used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy)"
}

variable "oidc_issuer_url" {
  description = "Issuer URL used to authenticate to Grafana, AlertManager and Prometheus (oauth2-proxy)"
}

variable "ingress_redirect" {
  description = "Enable ingress_redirect, to use live_domain, 'cloud-platform.service.justice.gov.uk'"
  type        = bool
  default     = false
}
variable "eks_cluster_oidc_issuer_url" {
  description = "This is going to be used when we create the IAM OIDC role"
  type        = string
  default     = ""
}

variable "dockerhub_username" {
  description = "DockerHub username - required to avoid hitting Dockerhub API limits in EKS clusters"
  default     = ""
  type        = string
}

variable "enable_large_nodesgroup" {
  description = "Due to Prometheus resource consumption, enabling this will set k8s Prometheus resources to higher values"
  type        = bool
  default     = false
}

variable "dockerhub_password" {
  description = "DockerHub password - required to avoid hitting Dockerhub API limits in EKS clusters"
  default     = ""
  type        = string
}

variable "kibana_upstream" {
  description = "ES upstream for logs"
  default     = ""
  type        = string
}

variable "kibana_audit_upstream" {
  description = "ES upstream for audit logs"
  default     = ""
  type        = string
}

variable "grafana_ingress_redirect_url" {
  description = "grafana url to use live_domain, 'cloud-platform.service.justice.gov.uk'"
  default     = ""
  type        = string
}

variable "prometheus_operator_crd_version" {
  default     = "v0.60.1"
  description = "The version of the prometheus operator crds matching the prometheus chart that is installed in monitoring module"
}

variable "dependence_ingress_controller" {
  description = "Ingress controller module dependences in order to be executed."
  type        = list(string)
}
