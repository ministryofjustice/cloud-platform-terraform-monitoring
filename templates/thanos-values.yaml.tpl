metrics:
  enabled: true
  serviceMonitor:
    enabled: true

storegateway:
  resources:
    limits:
      cpu: 1600m
      memory: 24Gi
    requests:
      cpu: 10m
      memory: 100Mi

  enabled: true
  serviceAccount:
    create: false
    name: "${prometheus_sa_name}"
  persistence:
    size: 75Gi
  podAnnotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
  extraFlags:
    - --min-time=-12w

query:
  resources:
    limits:
      cpu: 1600m
      memory: 24Gi
    requests:
      cpu: 10m
      memory: 100Mi

  ## @param query.replicaLabel Replica indicator(s) along which data is de-duplicated

  replicaLabel:
    - prometheus_replica

  stores:
    - prometheus-prometheus-operator-kube-p-prometheus-0.prometheus-operated.monitoring.svc:10901
    - prometheus-prometheus-operator-kube-p-prometheus-1.prometheus-operated.monitoring.svc:10901
    - prometheus-prometheus-operator-kube-p-prometheus-2.prometheus-operated.monitoring.svc:10901

queryFrontend:
  resources:
    limits:
      cpu: 1600m
      memory: 24Gi
    requests:
      cpu: 10m
      memory: 100Mi


ruler:
  enabled: true
  serviceAccount:
    create: false
    name: "${prometheus_sa_name}"
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
  extraFlags:
    - --compact.enable-vertical-compaction
    - --deduplication.replica-label=prometheus_replica
    - --deduplication.func=penalty
    - --compact.concurrency=64
    - --compact.blocks-fetch-concurrency=16
    - --delete-delay=12h
  retentionResolutionRaw: 30d
  retentionResolution5m: 183d
  retentionResolution1h: 365d
  persistence:
    size: 500Gi
  serviceAccount:
    create: false
    name: "${prometheus_sa_name}"
  resources:
    requests:
      cpu: 1500m
      memory: 1000Mi
    limits:
      cpu: 6500m
      memory: 5000Mi
bucketweb:
  resources:
    limits:
      cpu: 1600m
      memory: 24Gi
    requests:
      cpu: 10m
      memory: 100Mi
  enabled: true
  serviceAccount:
    create: false
    name: "${prometheus_sa_name}"

existingObjstoreSecret: thanos-objstore-config
existingObjstoreSecretItems:
  - key: thanos.yaml
    path: objstore.yml
