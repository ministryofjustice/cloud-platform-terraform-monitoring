- name: 'slack-$${severity}'
  slack_configs:
  - api_url: "$${webhook}"
    channel: "$${channel}"
    send_resolved: True
    title: '{{ template "slack.cp.title" . }}'
    text: '{{ template "slack.cp.text" . }}'
    footer: ${local.alertmanager_ingress}
    actions:
    - type: button
      text: 'Runbook :blue_book:'
      url: '{{ (index .Alerts 0).Annotations.runbook_url }}'
    - type: button
      text: 'Query :mag:'
      url: '{{ (index .Alerts 0).GeneratorURL }}'
    - type: button
      text: 'Dashboard :chart_with_upwards_trend:'
      url: '{{ (index .Alerts 0).Annotations.dashboard_url }}'
    - type: button
      text: 'Silence :no_bell:'
      url: '{{ template "__alert_silence_link" . }}'
- name: 'slack-info-$${severity}'
  slack_configs:
  - api_url: "$${webhook}"
    channel: "$${channel}"
    send_resolved: False
    title: '{{ template "slack.cp.title" . }}'
    text: '{{ template "slack.cp.text" . }}'
    color: 'good'
    footer: ${local.alertmanager_ingress}
    actions:
    - type: button
      text: 'Query :mag:'
      url: '{{ (index .Alerts 0).GeneratorURL }}'