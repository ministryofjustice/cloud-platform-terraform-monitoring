
existingServiceAccount: prometheus-operator-kube-p-prometheus

queryFrontend:
  ingress:
    ## @param bucketweb.ingress.enabled Enable ingress controller resource
    ##
    enabled: false
    ## @param bucketweb.ingress.hostname Default host for the ingress resource
    ##
    hostname: "${ grafana_ingress }"
    ingressClassName: "default"
    annotations: {
      external-dns.alpha.kubernetes.io/aws-weight: "100",
      external-dns.alpha.kubernetes.io/set-identifier: "dns-thanos",
      cloud-platform.justice.gov.uk/ignore-external-dns-weight: "true"
    }
    pathType: ImplementationSpecific

metrics:
  enabled: true
  serviceMonitor:
    enabled: true

storegateway:
  enabled: true
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
  extraFlags:
    - --min-time=-1w

query:
  stores:
    - prometheus-prometheus-operator-kube-p-prometheus-0.prometheus-operated.monitoring.svc:10901

ruler:
  enabled: true
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
  alertmanagers:
    - "http://alertmanager-operated.monitoring.svc:9093"
  existingConfigmap: prometheus-prometheus-operator-kube-p-prometheus-rulefiles-0
  clusterName: "${clusterName}"
  persistence:
    enabled: false

compactor:
  enabled:  ${enabled_compact}
  retentionResolutionRaw: 30d
  retentionResolution5m: 183d
  retentionResolution1h: 365d
  persistence:
    size: 500Gi

bucketweb:
  enabled: true

existingObjstoreSecret: thanos-objstore-config
existingObjstoreSecretItems:
  - key: thanos.yaml
    path: objstore.yml
