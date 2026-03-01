# Workastra Helm Chart

Deploy the Workastra application suite on Kubernetes using this Helm chart.

## Repository Overview

This repository contains Helm charts for deploying Workastra applications on Kubernetes.

### Directory Structure

```
workastra/helm/          # Main Helm charts repository
├── README.md            # This file - Quick start guide
├── ct.yaml              # Chart Testing config
├── charts/
│   ├── workastra/       # Main parent chart
│   │   ├── README.md    # Detailed workastra chart configuration
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── charts/
│   │       └── desk/    # Desk sub-chart dependency
│   └── desk/            # Desk application chart source
│       ├── README.md    # Detailed desk chart configuration
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/   # Kubernetes resource templates
```

### Charts

| Chart | Purpose | Location |
|-------|---------|----------|
| **workastra** | Parent chart that deploys the complete Workastra stack | `./charts/workastra/` |
| **desk** | Desk application component with Kubernetes resources | `./charts/desk/` |

For detailed configuration options of each chart, see:
- [Workastra Chart Documentation](./charts/workastra/README.md)
- [Desk Chart Documentation](./charts/desk/README.md)

## Prerequisites

- **Kubernetes** v1.24+
- **Helm** v3.10+
- **Gateway API Controller** (Envoy Gateway, Kong, or NGINX Gateway)
- **kubectl** configured

## Quick Start

```bash
cd /path/to/workastra/helm

helm install workastra ./charts/workastra \
  --namespace workastra \
  --create-namespace
```

> **Note**: Requires Gateway API resources setup first.

## Gateway API Setup

### 1. Install Gateway API Controller

For **Envoy Gateway**:
```bash
helm repo add envoy https://envoyproxy.io/charts
helm repo update
helm install eg-release envoy/gateway-helm-chart \
  --namespace envoy-gateway-system \
  --create-namespace
```

### 2. Create Gateway Resources

```bash
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: eg
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: eg
  namespace: default
spec:
  gatewayClassName: eg
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: All
EOF
```

Verify:
```bash
kubectl get gateway
kubectl get gatewayclass
```

## Installation

### Basic Install

```bash
helm install workastra ./charts/workastra \
  --namespace workastra \
  --create-namespace
```

### Install with Custom Values

Create `values.yaml`:

```yaml
desk:
  replicaCount: 3
  image:
    tag: "1.0.0"
  tenant:
    scheme: https
    domain: workastra.example.com
  httpRoute:
    hostnames:
      - workastra.example.com
  secrets:
    keys:
      - "app-key"
    oauth2:
      clientSecret: "secret"
```

Install:
```bash
helm install workastra ./charts/workastra \
  --namespace workastra \
  --create-namespace \
  --values values.yaml
```

### Update Installation

```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --values values.yaml
```

## Configuration

### Key Options

| Option | Default | Description |
|--------|---------|-------------|
| `desk.enabled` | `true` | Enable Desk deployment |
| `desk.replicaCount` | `1` | Number of replicas |
| `desk.image.repository` | `docker.io/library/workastra-desk` | Image repo |
| `desk.image.tag` | `latest` | Image tag |
| `desk.service.port` | `3000` | Service port |
| `desk.tenant.scheme` | `http` | HTTP or HTTPS |
| `desk.tenant.domain` | `workastra.com` | Domain name |
| `desk.httpRoute.enabled` | `true` | Enable HTTPRoute |
| `desk.secrets.keys` | `[]` | App keys |
| `desk.autoscaling.enabled` | `false` | Enable auto-scaling |

## Common Use Cases

**Development Setup:**
```bash
helm install workastra ./charts/workastra \
  --namespace workastra --create-namespace \
  --set desk.image.tag="dev-latest"
```

**Production Setup with HTTPS:**
```bash
helm install workastra ./charts/workastra \
  --namespace workastra --create-namespace \
  --set desk.replicaCount=3 \
  --set desk.tenant.scheme=https \
  --set desk.tenant.domain=workastra.example.com \
  --set desk.autoscaling.enabled=true
```

**Scale Up:**
```bash
helm upgrade workastra ./charts/workastra \
  --namespace workastra \
  --set desk.replicaCount=5
```

**Disable HTTPRoute:**
```bash
helm install workastra ./charts/workastra \
  --namespace workastra --create-namespace \
  --set desk.httpRoute.enabled=false
```

## Troubleshooting

**Check deployment status:**
```bash
kubectl get pods -n workastra
kubectl logs <pod-name> -n workastra
```

**Check Gateway API:**
```bash
kubectl get gateway
kubectl get gatewayclass
```

**View current values:**
```bash
helm get values workastra -n workastra
```

**View manifest:**
```bash
helm get manifest workastra -n workastra
```

**Uninstall:**
```bash
helm uninstall workastra -n workastra
kubectl delete namespace workastra
```

## Useful Commands

```bash
helm install workastra ./charts/workastra -n workastra --create-namespace
helm upgrade workastra ./charts/workastra -n workastra
helm status workastra -n workastra
helm values workastra -n workastra
helm rollback workastra 1 -n workastra
```

## Resources

- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Helm Docs](https://helm.sh/docs/)
- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [Envoy Gateway](https://gateway.envoyproxy.io/)
