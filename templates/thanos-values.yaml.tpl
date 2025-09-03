metrics:
  enabled: true
  serviceMonitor:
    enabled: true

storegateway:
  resources:
    limits:
      cpu: 2000m
      memory: 32Gi
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
  replicaCount: "${thanos_query_replica_count}"
  resources:
    limits:
      cpu: 3000m
      memory: 45Gi
    requests:
      cpu: 10m
      memory: 100Mi
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: cloud-platform.justice.gov.uk/monitoring-ng
            operator: In
            values:
            - "true"
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values:
            - "eu-west-2a"
            - "eu-west-2b"
            - "eu-west-2c"
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/instance
                operator: In
                values:
                - prometheus-operator-kube-p-prometheus
              - key: app.kubernetes.io/component
                operator: In
                values:
                - query
          topologyKey: topology.kubernetes.io/zone

  extraFlags:
    - --query.timeout=5m

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
      cpu: 2000m
      memory: 38Gi
    requests:
      cpu: 800m
      memory: 12Gi


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
    - --downsample.concurrency=16
    - --compact.blocks-fetch-concurrency=16
    - --delete-delay=12h
    - --no-debug.halt-on-error
  retentionResolutionRaw: 30d
  retentionResolution5m: 180d
  retentionResolution1h: 365d
  persistence:
    size: 16000Gi
  serviceAccount:
    create: false
    name: "${prometheus_sa_name}"
  tolerations:
    - key: "thanos-node"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule"

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: cloud-platform.justice.gov.uk/thanos-ng
            operator: In
            values:
            - "true"
  resources:
    requests:
      cpu: 1500m
      memory: 1000Mi
    limits:
      cpu: 7800m
      memory: 30000Mi
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

image:
  registry: docker.io
  repository: bitnamilegacy/thanos
  tag: 0.39.2-debian-12-r2
  pullPolicy: IfNotPresent


########################################
# bitnami legacy images issue:
#
# Bitnami's introduction of 'production-ready' secure images topic:
# https://github.com/bitnami/charts/issues/35164
# 
# As a temp measure we are switching over to legacy registry. This means the chart complains about insecure images (this is by Bitnami design):
#
# ERROR: Original containers have been substituted for unrecognized ones. Deploying this chart with non-standard containers is likely to cause degraded security and performance, broken chart features, and missing environment variables.
# 
# Unrecognized images:
#    - docker.io/bitnamilegacy/0.34.1-debian-12-r1
#
# If you are sure you want to proceed with non-standard containers, you can skip container image verification by setting the global parameter 'global.security.allowInsecureImages' to true.
# Further information can be obtained at https://github.com/bitnami/charts/issues/30850
#
# Therefore we are setting: 
# global.security.allowInsecureImages: true
# 
# This solution will only help us until we pass version 0.39 of thanos:
# https://hub.docker.com/r/bitnamilegacy/thanos/tags
#
# After which we need to do something else:
# 
# - Investigate alternatives
# - subscribe to bitnami?
#
########################################
global:
  security:
    allowInsecureImages: true