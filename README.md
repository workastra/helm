# Workastra Helm Chart

Deploy the complete Workastra application suite on Kubernetes using this unified Helm chart.

## Repository Overview

This repository contains a single Helm chart for deploying the entire Workastra stack on Kubernetes.

### Directory Structure

```
workastra/helm/          # Main Helm charts repository
├── README.md            # This file - Quick start guide
├── Chart.yaml           # Chart metadata
├── values.yaml          # Default configuration values
├── templates/           # Kubernetes resource templates
│   ├── _helpers.tpl     # Helm template helpers
│   ├── desk/            # Desk service templates
│   ├── iam/             # IAM service templates
│   └── migration/       # Migration job templates
├── .github/
│   └── actions/deploy/  # Taskfile-based deployment automation
└── ct.yaml              # Chart Testing configuration
```

### Services

This chart deploys three main services:

| Service | Purpose | Port | Always Deployed |
|---------|---------|------|-----------------|
| **desk** | Main application interface | 3000 | ❌ Optional |
| **iam** | Identity and Access Management | 9000 | ✅ Core component |
| **migration** | Database migration job | N/A | ✅ Core component |

## Prerequisites

- **Kubernetes** v1.24+
- **Helm** v3.10+
- **Gateway API Controller** (Envoy Gateway, Kong, or NGINX Gateway)
- **kubectl** configured
- **Task** (optional, for automated deployment)

## Quick Start

### Option 1: Manual Helm Installation

```bash
cd /path/to/workastra/helm

# Install with default values
helm install workastra . \
  --namespace workastra \
  --create-namespace

# Or with custom values
helm install workastra . \
  --namespace workastra \
  --create-namespace \
  --set desk.image.repository=myregistry/desk \
  --set iam.image.repository=myregistry/iam \
  --set migration.image.repository=myregistry/migration
```

### Option 2: Automated Deployment (Recommended)

Use the included Taskfile for complete infrastructure setup:

```bash
cd /path/to/workastra/helm

# Full deployment (gateway, postgres, workastra)
task --dir .github/actions/deploy deploy

# Or just deploy the application (requires existing infra)
task --dir .github/actions/deploy workastra:deploy
```

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
helm install workastra . \
  --namespace workastra \
  --create-namespace
```

### Install with Custom Values

Create `values.yaml`:

```yaml
global:
  tenant:
    scheme: https
    domain: workastra.example.com

desk:
  replicaCount: 3
  image:
    tag: "1.0.0"
  httpRoute:
    hostnames:
      - workastra.example.com
  secrets:
    keys:
      - "app-key"
    oauth2:
      clientSecret: "secret"

iam:
  replicaCount: 2
  image:
    tag: "1.0.0"

migration:
  image:
    tag: "1.0.0"
```

Install:
```bash
helm install workastra . \
  --namespace workastra \
  --create-namespace \
  --values values.yaml
```

### Update Installation

```bash
helm upgrade workastra . \
  --namespace workastra \
  --values values.yaml
```

## Configuration

### Key Options

| Option | Default | Description |
|--------|---------|-------------|
| `global.tenant.scheme` | `http` | HTTP or HTTPS for all services |
| `global.tenant.domain` | `workastra.com` | Domain name for routing |
| `desk.enabled` | `true` | Enable Desk deployment |
| `desk.replicaCount` | `1` | Number of Desk replicas |
| `desk.image.repository` | `workastra/desk` | Desk image repository |
| `desk.image.tag` | `latest` | Desk image tag |
| `desk.service.port` | `3000` | Desk service port |
| `desk.httpRoute.enabled` | `true` | Enable Desk HTTPRoute |
| `desk.httpRoute.hostnames` | `["workastra.com"]` | Desk hostnames |
| `desk.httpRoute.parentRefs` | Gateway reference | Gateway parent references |
| `desk.secrets.keys` | `[]` | Array of app keys (first is current, rest are previous) |
| `desk.secrets.oauth2.clientSecret` | `""` | OAuth2 client secret |
| `desk.resources` | `{}` | Desk resource limits/requests |
| `iam.replicaCount` | `1` | Number of IAM replicas |
| `iam.image.repository` | `workastra/iam` | IAM image repository |
| `iam.image.tag` | `latest` | IAM image tag |
| `iam.service.port` | `9000` | IAM service port |
| `iam.resources` | `{}` | IAM resource limits/requests |
| `migration.image.repository` | `workastra/migration` | Migration image repository |
| `migration.image.tag` | `latest` | Migration image tag |
| `migration.env` | `[]` | Migration environment variables |

## Common Use Cases

**Development Setup:**
```bash
helm install workastra . \
  --namespace workastra --create-namespace \
  --set desk.image.tag="dev-latest" \
  --set iam.image.tag="dev-latest" \
  --set migration.image.tag="dev-latest"
```

**Production Setup with HTTPS:**
```bash
helm install workastra . \
  --namespace workastra --create-namespace \
  --set global.tenant.scheme=https \
  --set global.tenant.domain=workastra.example.com \
  --set desk.replicaCount=3 \
  --set iam.replicaCount=2
```

**Scale Services:**
```bash
helm upgrade workastra . \
  --namespace workastra \
  --set desk.replicaCount=5 \
  --set iam.replicaCount=3
```

**Disable Components:**
```bash
helm install workastra . \
  --namespace workastra --create-namespace \
  --set desk.httpRoute.enabled=false \
  --set desk.enabled=false
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
helm install workastra . -n workastra --create-namespace
helm upgrade workastra . -n workastra
helm status workastra -n workastra
helm values workastra -n workastra
helm rollback workastra 1 -n workastra
```

## Resources

- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Helm Docs](https://helm.sh/docs/)
- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [Envoy Gateway](https://gateway.envoyproxy.io/)
