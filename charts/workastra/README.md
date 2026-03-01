# Workastra Chart

Parent Helm chart for deploying the complete Workastra application stack.

**Chart Version:** 0.1.0  
**Application Version:** 0.0.1

## Overview

The Workastra chart is a parent (umbrella) chart that manages the deployment of the Desk application and all its dependencies.

### What It Includes

- **Desk Application**: Main application component
- **Kubernetes Resources**: Services, ConfigMaps, Secrets, ServiceAccounts
- **Gateway API Integration**: HTTPRoute for external access
- **Auto-scaling**: Optional HPA (Horizontal Pod Autoscaler)
- **Health Checks**: Liveness and readiness probes

## Chart Dependencies

This chart depends on the **Desk** sub-chart:

```yaml
dependencies:
  - name: desk
    version: 0.2.0
    repository: "file://../desk"
```

For Desk chart configuration details, see [Desk Chart Documentation](../desk/README.md).

## Installation

### Basic Installation

```bash
helm install workastra ./charts/workastra \
  --namespace workastra \
  --create-namespace
```

### Installation with Values File

```bash
helm install workastra ./charts/workastra \
  --namespace workastra \
  --create-namespace \
  --values values.yaml
```

### Upgrade Existing Installation

```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --values values.yaml
```

## Configuration Reference

All configuration is under the `desk` key since this is a parent chart that wraps the Desk sub-chart.

### Core Settings

```yaml
desk:
  enabled: true              # Enable/disable Desk deployment
  replicaCount: 1            # Number of pod replicas
```

### Image Configuration

```yaml
desk:
  image:
    repository: docker.io/library/workastra-desk
    tag: latest              # Use specific version instead of 'latest'
    pullPolicy: IfNotPresent  # IfNotPresent, Always, or Never
```

### Service Configuration

```yaml
desk:
  service:
    type: ClusterIP          # ClusterIP, NodePort, or LoadBalancer
    port: 3000               # Service port
```

### Tenant Configuration

```yaml
desk:
  tenant:
    scheme: http             # http or https
    domain: workastra.com    # Application domain
```

### HTTPRoute Configuration (Gateway API)

```yaml
desk:
  httpRoute:
    enabled: true                    # Enable Gateway API HTTPRoute
    annotations: {}                  # Additional annotations
    hostnames:                       # List of hostnames
      - workastra.com
    parentRefs:                      # Gateway references
      - name: eg                     # Gateway name
        namespace: default           # Gateway namespace
        sectionName: http            # Gateway listener name
    rules: []                        # HTTPRoute rules
```

### Secrets Configuration

```yaml
desk:
  secrets:
    keys: []                         # App secret keys
    oauth2:
      clientSecret: ""               # OAuth2 client secret
```

### Auto-scaling Configuration

```yaml
desk:
  autoscaling:
    enabled: false                   # Enable HPA
    minReplicas: 1
    maxReplicas: 100
    targetCPUUtilizationPercentage: 80
```

### Resource Limits

```yaml
desk:
  resources:                         # Pod resource requests/limits
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "500m"
```

## Passing Values to Sub-chart

Since this is a parent chart, all Desk configuration goes under the `desk` key:

```yaml
# values.yaml
desk:
  enabled: true
  replicaCount: 3
  image:
    tag: "1.0.0"
  tenant:
    scheme: https
    domain: myapp.example.com
  secrets:
    keys:
      - "my-app-key"
    oauth2:
      clientSecret: "my-secret"
```

Install with this values:

```bash
helm install workastra ./charts/workastra \
  --namespace workastra \
  --create-namespace \
  --values values.yaml
```

## Common Tasks

### Change Image Version

```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --set desk.image.tag="v1.2.0"
```

### Scale Replicas

```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --set desk.replicaCount=5
```

### Enable HTTPS

```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --set desk.tenant.scheme=https \
  --set desk.tenant.domain=myapp.example.com
```

### Enable Auto-scaling

```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --set desk.autoscaling.enabled=true \
  --set desk.autoscaling.minReplicas=2 \
  --set desk.autoscaling.maxReplicas=10
```

### Disable HTTPRoute

```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --set desk.httpRoute.enabled=false
```

## Troubleshooting

### Check Values

```bash
helm get values workastra -n workastra
```

### Render Templates

```bash
helm template workastra ./charts/workastra \
  --namespace workastra \
  --values values.yaml
```

### Verify Desk Sub-chart

All Desk configuration details are in [Desk Chart Documentation](../desk/README.md).

### Check Deployment

```bash
kubectl get pods -n workastra
kubectl describe pod <pod-name> -n workastra
kubectl logs <pod-name> -n workastra
```

## See Also

- [Desk Chart Documentation](../desk/README.md) - Details about the Desk application component
- [Main Repository README](../../README.md) - Quick start guide
