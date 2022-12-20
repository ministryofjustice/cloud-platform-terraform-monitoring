# Default values for metrics-server.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

image:
  repository: registry.k8s.io/metrics-server/metrics-server
  # Overrides the image tag whose default is v{{ .Chart.AppVersion }}
  tag: ""
  pullPolicy: IfNotPresent

serviceAccount:
  # Specifies whether a service account should be created
  create: true


rbac:
  # Specifies whether RBAC resources should be created
  create: true
  pspEnabled: false

apiService:
  # Specifies if the v1beta1.metrics.k8s.io API service should be created.
  #
  # You typically want this enabled! If you disable API service creation you have to
  # manage it outside of this chart for e.g horizontal pod autoscaling to
  # work with this release.
  create: true
  # Annotations to add to the API service
  annotations: {}
  # Specifies whether to skip TLS verification
  insecureSkipTLSVerify: true
  # The PEM encoded CA bundle for TLS verification
  caBundle: ""

priorityClassName: system-cluster-critical

containerPort: 10250

replicas: 1

defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s


livenessProbe:
  httpGet:
    path: /livez
    port: https
    scheme: HTTPS
  initialDelaySeconds: 0
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /readyz
    port: https
    scheme: HTTPS
  initialDelaySeconds: 20
  periodSeconds: 10
  failureThreshold: 3

service:
  type: ClusterIP
  port: 443
  annotations: {}
  labels: {}
  #  Add these labels to have metrics-server show up in `kubectl cluster-info`
  #  kubernetes.io/cluster-service: "true"
  #  kubernetes.io/name: "Metrics-server"

metrics:
  enabled: true

serviceMonitor:
  enabled: true
  additionalLabels: {}
  interval: 1m
  scrapeTimeout: 10s
  metricRelabelings: []
  relabelings: []
