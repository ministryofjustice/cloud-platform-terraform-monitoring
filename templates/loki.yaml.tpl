
loki:
  enabled: true
  env:
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          key: access_key_id
          name: loki 
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          key: secret_access_key
          name: loki
  config:
    schema_config:
      configs:
      - from: 2020-11-24
        store: aws
        object_store: s3
        schema: v11
        index:
          prefix: cp_loki
          period: 0
    storage_config:
      aws:
        s3: s3://eu-west-2/cp-loki-logs-test
        dynamodb:
          dynamodb_url: dynamodb://eu-west-2
    table_manager:
      retention_deletes_enabled: true
      retention_period: 720h

promtail:
  enabled: true

fluent-bit:
  enabled: false

grafana:
  enabled: false
  sidecar:
    datasources:
      enabled: true
  image:
    tag: 6.7.0

prometheus:
  enabled: false
