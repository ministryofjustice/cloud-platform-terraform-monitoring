# Default values for prometheus-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

## Create default rules for monitoring the cluster
##
defaultRules:
  create: true
  rules:
%{ if eks ~}
    kubeScheduler: false
    etcd: false
%{ endif ~}
    general: false
    kubernetesApps: false

## Configuration for alertmanager
## ref: https://prometheus.io/docs/alerting/alertmanager/
##
alertmanager:
  ## Alertmanager configuration directives
  ## ref: https://prometheus.io/docs/alerting/configuration/#configuration-file
  ##      https://prometheus.io/webtools/alerting/routing-tree-editor/
  ##
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname', 'job']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: 'null'
      routes:
      - match:
          alertname: KubeQuotaExceeded
        receiver: 'null'
      - match:
          alertname: CPUThrottlingHigh
        receiver: 'null'
      - match:
          alertname: DeadMansSwitch
        receiver: 'null'
      - match:
          alertname: AggregatedAPIDown
        receiver: 'null'
      - match:
          alertname: DeploymentReplicasAreOutdated
        receiver: 'null'
      - match:
          alertname: PodIsRestartingFrequently
        receiver: 'null'
      - match:
          alertname: KubePersistentVolumeFullInFourDays
        receiver: 'null'
      - match:
          alertname: PrometheusTargetScrapesDuplicate
        receiver: 'null'
      - match:
          alertname: KubeAPILatencyHigh
        receiver: 'null'
      
      - match:
          severity: critical
        receiver: pager-duty-high-priority
      ${indent(6, alertmanager_routes)}
    receivers:
    - name: 'null'
    # Add PagerDuty key to allow integration with a PD service.
    - name: 'pager-duty-high-priority'
      pagerduty_configs:
      - service_key: "${ pagerduty_config }"
    ${indent(4, alertmanager_receivers)}
    templates:
    - '/etc/alertmanager/config/cp-slack-templates.tmpl'

  ## Alertmanager template files to format alerts
  ## ref: https://prometheus.io/docs/alerting/notifications/
  ##      https://prometheus.io/docs/alerting/notification_examples/
  ##
  templateFiles:
    cp-slack-templates.tmpl: |-
      {{ define "slack.cp.title" -}}
        [{{ .Status | toUpper -}}
        {{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{- end -}}
        ] {{ template "__alert_severity_prefix_title" . }} {{ .CommonLabels.alertname }}
      {{- end }}

      {{/* The test to display in the alert */}}
      {{ define "slack.cp.text" -}}
        {{ range .Alerts }}
            *Alert:* {{ .Annotations.message}}
            *Details:*
            {{ range .Labels.SortedPairs }} - *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
            *-----*
          {{ end }}
      {{- end }}

      {{ define "__alert_silence_link" -}}
        {{ .ExternalURL }}/#/silences/new?filter=%7B
        {{- range .CommonLabels.SortedPairs -}}
          {{- if ne .Name "alertname" -}}
            {{- .Name }}%3D"{{- .Value -}}"%2C%20
          {{- end -}}
        {{- end -}}
          alertname%3D"{{ .CommonLabels.alertname }}"%7D
      {{- end }}

      {{ define "__alert_severity_prefix" -}}
          {{ if ne .Status "firing" -}}
          :white_check_mark:
          {{- else if eq .Labels.severity "critical" -}}
          :fire:
          {{- else if eq .Labels.severity "warning" -}}
          :warning:
          {{- else -}}
          :question:
          {{- end }}
      {{- end }}

      {{ define "__alert_severity_prefix_title" -}}
          {{ if ne .Status "firing" -}}
          :white_check_mark:
          {{- else if eq .CommonLabels.severity "critical" -}}
          :fire:
          {{- else if eq .CommonLabels.severity "warning" -}}
          :warning:
          {{- else if eq .CommonLabels.severity "info" -}}
          :information_source:
          {{- else if eq .CommonLabels.status_icon "information" -}}
          :information_source:
          {{- else -}}
          :question:
          {{- end }}
      {{- end }}

  ## Settings affecting alertmanagerSpec
  ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#alertmanagerspec
  ##
  alertmanagerSpec:
   ## Log level for Alertmanager to be configured with.
    ##
    logLevel: info

    ## Storage is the definition of how storage will be used by the Alertmanager instances.
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/storage.md
    ##
    storage:
    volumeClaimTemplate:
      spec:
        storageClassName: ${storage_class}
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
      selector: {}

    ## 	The external URL the Alertmanager instances will be available under. This is necessary to generate correct URLs. This is necessary if Alertmanager is not served from root of a DNS name.	string	false
    ##
    externalUrl: "${ alertmanager_ingress }"

## Using default values from https://github.com/helm/charts/blob/master/stable/grafana/values.yaml
##
grafana:
  enabled: true

  image:
    repository: grafana/grafana
    tag: 7.0.2
    pullPolicy: IfNotPresent

%{ if eks ~}
  serviceAccount:
    create: true
    annotations:
      eks.amazonaws.com/role-arn: "${grafana_assumerolearn}"
%{ endif ~}

  adminUser: "${ random_username }"
  adminPassword: "${ random_password }"

  ## Pod Annotations
%{ if eks == false ~}
  podAnnotations: 
    iam.amazonaws.com/role: "${ grafana_pod_annotation }"
%{ endif ~}

  ingress:
    enabled: true
    annotations: 
      kubernetes.io/ingress.class: monitoring
    hosts:
    - "${ grafana_ingress }"
    tls:
      - hosts:
        - "${ grafana_ingress }"

  env:
    GF_SERVER_ROOT_URL: "${ grafana_root }"
    GF_ANALYTICS_REPORTING_ENABLED: "false"
    GF_AUTH_DISABLE_LOGIN_FORM: "true"
    GF_USERS_ALLOW_SIGN_UP: "false"
    GF_USERS_AUTO_ASSIGN_ORG_ROLE: "Viewer"
    GF_USERS_VIEWERS_CAN_EDIT: "true"
    GF_SMTP_ENABLED: "false"
    GF_AUTH_GENERIC_OAUTH_ENABLED: "true"
    GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP: "true"
    GF_AUTH_GENERIC_OAUTH_NAME: "Auth0"
    GF_AUTH_GENERIC_OAUTH_SCOPES: "openid profile email"

  envFromSecret: "grafana-env"

  serverDashboardConfigmaps:
    - grafana-user-dashboards

  sidecar:
    dashboards:
      enabled: true
      label: grafana_dashboard
      searchNamespace: ALL
    datasources:
      enabled: true
      label: grafana_datasource

  ## Configure additional grafana datasources
  ## ref: http://docs.grafana.org/administration/provisioning/#datasources
  additionalDataSources:
  - name: Cloudwatch
    type: cloudwatch
    editable: true
    access: proxy
    jsonData:
      authType: arn
      defaultRegion: eu-west-2
      assumeRoleArn: "${ grafana_assumerolearn }"
    orgId: 1
    version: 1

## Component scraping coreDns. Use either this or kubeDns
##
coreDns:
%{ if eks ~}
  enabled: true
%{ else ~}
  enabled: false
%{ endif ~}

## Component scraping kubeDns. Use either this or coreDns
##
kubeDns:
%{ if eks ~}
  enabled: false
%{ else ~}
  enabled: true
%{ endif ~}


## Component scraping etcd
##
kubeEtcd:
%{ if eks ~}
  enabled: false
%{ else ~}
  enabled: true
%{ endif ~}

## Component scraping kube scheduler
##
kubeScheduler:
%{ if eks ~}
  enabled: false
%{ else ~}
  enabled: true
  ## If using kubeScheduler.endpoints only the port and targetPort are used
  ##
  service:
    selector:
      k8s-app: kube-scheduler
%{ endif ~}


kubeProxy:
%{ if eks ~}
  enabled: false
%{ else ~}
  enabled: true
%{ endif ~}

## Component scraping the kube controller manager
##
kubeControllerManager:
%{ if eks ~}
  enabled: false
%{ else ~}
  enabled: true
%{ endif ~}

  ## If using kubeControllerManager.endpoints only the port and targetPort are used
  ##
  service:
    selector:
      k8s-app: kube-controller-manager

## Component scraping kube state metrics
##
kubeStateMetrics:
  enabled: true

## Configuration for kube-state-metrics subchart
##
kube-state-metrics:
  image:
    tag: v1.7.0

  collectors:
    validatingwebhookconfigurations: false
    networkpolicies: false
    volumeattachments: false
    mutatingwebhookconfigurations: false
    verticalpodautoscalers: false

## Manages Prometheus and Alertmanager components
##
prometheusOperator:
  enabled: true

  tlsProxy:
    enabled: false

  admissionWebhooks:
    enabled: false

  ## Deploy CRDs used by Prometheus Operator.
  ##
  createCustomResource: true

  ## Attempt to clean up CRDs created by Prometheus Operator.
  ##
  cleanupCustomResource: true

## Deploy a Prometheus instance
##
prometheus:

  enabled: true

%{ if eks ~}
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: "${eks_service_account}"
%{ endif ~}
      

  ## Settings affecting prometheusSpec
  ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#prometheusspec
  ##
  prometheusSpec:

    %{ if enable_prometheus_affinity_and_tolerations ~}
    ## Tolerations for use with node taints
    ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
    ##
    tolerations:
      - key: "monitoring-node"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
    %{ endif ~}

    ## External labels to add to any time series or alerts when communicating with external systems
    ##    
    externalLabels:
      clusterName: "${clusterName}"

    ## External URL at which Prometheus will be reachable.
    ##
    externalUrl: "${ prometheus_ingress }"

    ## If true, a nil or {} value for prometheus.prometheusSpec.ruleSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the PrometheusRule resources created
    ##
    ruleSelectorNilUsesHelmValues: false

    ## Rules CRD selector
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/design.md
    ## If unspecified the release `app` and `release` will be used as the label selector
    ## to load rules
    ##
    ruleSelector: {}

    ## Namespaces to be selected for PrometheusRules discovery.
    ## If nil, select own namespace. Namespaces to be selected for ServiceMonitor discovery.
    ## See https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#namespaceselector for usage
    ##
    ruleNamespaceSelector: {}

    ## If true, a nil or {} value for prometheus.prometheusSpec.serviceMonitorSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the servicemonitors created
    ##
    serviceMonitorSelectorNilUsesHelmValues: false

    ## serviceMonitorSelector will limit which servicemonitors are used to create scrape
    ## configs in Prometheus. See serviceMonitorSelectorUseHelmLabels
    ##
    serviceMonitorSelector: {}

    ## serviceMonitorNamespaceSelector will limit namespaces from which serviceMonitors are used to create scrape
    ## configs in Prometheus. By default all namespaces will be used
    ##
    serviceMonitorNamespaceSelector: {}

    ## If true, a nil or {} value for prometheus.prometheusSpec.podMonitorSelector will cause the
    ## prometheus resource to be created with selectors based on values in the helm deployment,
    ## which will also match the podmonitors created
    ##
    podMonitorSelectorNilUsesHelmValues: false

    ## PodMonitors to be selected for target discovery.
    ## If {}, select all PodMonitors
    ##
    podMonitorSelector: {}

    ## Namespaces to be selected for PodMonitor discovery.
    ## See https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#namespaceselector for usage
    ##
    podMonitorNamespaceSelector: {}

    ## How long to retain metrics
    ##
    retention: 1d

%{ if eks == false ~}
    podMetadata:
      annotations:
        iam.amazonaws.com/role: "${monitoring_aws_role}"
%{ endif ~}

    %{ if enable_prometheus_affinity_and_tolerations ~}
    ## Assign custom affinity rules to the prometheus instance
    ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
    ##
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: beta.kubernetes.io/instance-type
              operator: In
              values:
              - r5.2xlarge
    %{ endif ~}

    ## Prometheus StorageSpec for persistent data
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/storage.md
    ##
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: ${storage_class}
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 750Gi

    thanos: 
      baseImage: quay.io/thanos/thanos
      version: v0.11.0
      objectStorageConfig:
        key: thanos.yaml
        name: thanos-objstore-config 

