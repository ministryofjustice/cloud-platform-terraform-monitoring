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
    - prometheus-operator-kube-p-prometheus.prometheus-operated.monitoring.svc:10901
compactor:
  enabled: "${enabled_compact}"
  retentionResolutionRaw: 30d
  retentionResolution5m: 183d
  retentionResolution1h: 365d
  persistence:
    size: 350Gi
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
bucketweb:
  enabled: true
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"

existingObjstoreSecret: thanos-objstore-config
existingObjstoreSecretItems:
  - key: thanos.yaml
    path: objstore.yml
