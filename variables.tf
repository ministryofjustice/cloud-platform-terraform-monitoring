variable "alertmanager_slack_receivers" {
  description = "A list of configuration values for Slack receivers"
  type        = list
}

variable "iam_role_nodes" {
  description = "Nodes IAM role ARN in order to create the KIAM/Kube2IAM"
  type        = string
}

variable "pagerduty_config" {
  description = "Add PagerDuty key to allow integration with a PD service."
}

variable "dependence_opa" {
  description = "OPA module dependences in order to be executed."
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

variable "split_prometheus" {
  description = "Create a second Prometheus which will match (for rules) only rules with release=prometheus-operator labels and make the main prometheus only look for prometheus=cloud-platform (more info in the README)"
  type        = bool
  default     = false
}

# EKS variables
variable "eks" {
  description = "Where are you applying this modules in kOps cluster or in EKS (KIAM or KUBE2IAM?)"
  type        = bool
  default     = false
}

variable "eks_cluster_oidc_issuer_url" {
  description = "If EKS variable is set to true this is going to be used when we create the IAM OIDC role"
  type        = string
  default     = ""
}
