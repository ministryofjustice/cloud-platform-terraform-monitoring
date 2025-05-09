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

variable "thanos_query_replica_count" {
  description = "the number of thanos query replicas"
  default     = 1
  type        = number
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

variable "large_nodesgroup_cpu_requests" {
  description = "CPU requests for large nodesgroup"
  type        = string
  default     = "1300m"
}

variable "large_nodesgroup_memory_requests" {
  description = "Memory requests for large nodesgroup"
  type        = string
  default     = "14000Mi"
}

variable "dockerhub_password" {
  description = "DockerHub password - required to avoid hitting Dockerhub API limits in EKS clusters"
  default     = ""
  type        = string
}

variable "eks_cluster_name" {
  default = "live"
}

variable "business_unit" {
  default = "Platforms"
}

variable "application" {
  default = "Monitoring"
}

variable "is_production" {
  default = "true"
}

variable "team_name" {
  default = "webops"
}

variable "environment" {
  default = "production"
}

variable "infrastructure_support" {
  default = "Cloud Platform"
}

variable "enable_rds_exporter" {
  description = "Whether or not to enable the RDS exporter"
  default     = false
  type        = bool
}

variable "enable_subnet_exporter" {
  description = "Whether or not to enable the Subnet exporter"
  default     = false
  type        = bool
}

variable "aws_subnet_exporter_image_tag" {
  description = "Tag of the subnet exporter image to use"
  default     = ""
  type        = string
}
