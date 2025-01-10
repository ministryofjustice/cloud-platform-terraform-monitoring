- match:
    severity: info-${severity}
  receiver: slack-info-${severity}
  continue: true
- match:
    severity: ${severity}
  receiver: slack-${severity}