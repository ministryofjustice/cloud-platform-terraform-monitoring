image:
  registry: quay.io
  repository: thanos/thanos
  tag: v0.18.0


%{ if eks ~}
existingServiceAccount: prometheus-operator-kube-p-prometheus
%{ endif ~}

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
%{ if eks == false ~}
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
%{ endif ~}

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
    size: 350Gi
%{ if eks == false ~}
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
%{ endif ~}

bucketweb:
  enabled: true
%{ if eks == false ~}
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
%{ endif ~}

existingObjstoreSecret: thanos-objstore-config
existingObjstoreSecretItems:
  - key: thanos.yaml
    path: objstore.yml
