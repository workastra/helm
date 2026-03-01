# Desk Chart

Helm chart for deploying the Workastra Desk application on Kubernetes.

**Chart Version:** 0.2.0  
**Kubernetes Compatibility:** v1.24+

## Overview

The Desk chart provides a complete Kubernetes deployment for the Workastra Desk application, including:

- **Deployment**: Managed pod replicas with health checks
- **Service**: Network access to the application
- **ConfigMaps**: Application configuration
- **Secrets**: Sensitive data (API keys, OAuth2 credentials)
- **ServiceAccount**: Kubernetes security and RBAC
- **HTTPRoute**: Gateway API integration for routing
- **HPA**: Horizontal Pod Autoscaler for auto-scaling
- **Health Checks**: Liveness and readiness probes

## Installation

### Basic Installation

```bash
helm install desk ./
```

### Installation in Namespace

```bash
helm install desk ./ \
  --namespace workastra \
  --create-namespace
```

### Installation with Custom Values

```bash
helm install desk ./ \
  --namespace workastra \
  --values values.yaml
```

## Configuration Reference

### Replica Count

```yaml
replicaCount: 1
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `replicaCount` | Number of pod replicas to deploy | `1` | `3` |

**Purpose**: Controls how many copies of the application run simultaneously. Increase for high availability and load distribution.

**Example**:
```bash
helm install desk ./ --set replicaCount=3
```

### Image Configuration

```yaml
image:
  repository: docker.io/library/workastra-desk
  pullPolicy: IfNotPresent
  tag: "latest"
```

| Field | Purpose | Default | Values |
|-------|---------|---------|--------|
| `image.repository` | Docker image repository URL | `docker.io/library/workastra-desk` | Any valid Docker registry URL |
| `image.pullPolicy` | When to pull the image from registry | `IfNotPresent` | `IfNotPresent`, `Always`, `Never` |
| `image.tag` | Docker image tag/version | `latest` | Any valid Docker tag (e.g., `v1.2.0`) |

**Purpose**: Specifies which Docker image to use and how to retrieve it:
- `repository`: Where to find the image
- `pullPolicy`: Controls caching behavior
- `tag`: Which version to deploy

**Example**:
```yaml
image:
  repository: myregistry.azurecr.io/workastra-desk
  pullPolicy: Always
  tag: "v1.2.0"
```

### Image Pull Secrets

```yaml
imagePullSecrets: []
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `imagePullSecrets` | Kubernetes secrets for private registry authentication | `[]` | `[{name: my-registry-secret}]` |

**Purpose**: Provides credentials to pull images from private Docker registries.

**Example**:
```yaml
imagePullSecrets:
  - name: my-registry-secret
```

### Service Account

```yaml
serviceAccount:
  create: true
  automount: true
  annotations: {}
  name: ""
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `serviceAccount.create` | Whether to create a service account | `true` | `false` |
| `serviceAccount.automount` | Auto-mount service account credentials to pods | `true` | `false` |
| `serviceAccount.annotations` | Kubernetes annotations for the service account | `{}` | `{iam.gke.io/gcp-service-account: my-account}` |
| `serviceAccount.name` | Service account name (auto-generated if empty) | `""` | `my-desk-sa` |

**Purpose**: Manages Kubernetes security and RBAC (Role-Based Access Control):
- `create`: Automatically create the service account
- `automount`: Make API credentials available to pods
- `annotations`: Add cloud provider specific permissions

### Pod Configuration

#### Labels and Annotations

```yaml
podLabels: {}
podAnnotations: {}
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `podLabels` | Kubernetes labels for pod identification and selection | `{}` | `{app: desk, tier: frontend}` |
| `podAnnotations` | Kubernetes annotations for metadata (e.g., monitoring, CI/CD) | `{}` | `{prometheus.io/scrape: "true"}` |

**Purpose**: Add metadata to pods:
- `podLabels`: Used by selectors and service discovery
- `podAnnotations`: Used by monitoring tools (Prometheus), admission controllers, etc.

**Example**:
```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "3000"
```

#### Security Context

```yaml
podSecurityContext: {}
securityContext: {}
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `podSecurityContext.fsGroup` | File system group for volume ownership | `undefined` | `2000` |
| `securityContext.capabilities` | Linux kernel capabilities to add/drop | `undefined` | `drop: [ALL]` |
| `securityContext.readOnlyRootFilesystem` | Make root filesystem read-only | `undefined` | `true` |
| `securityContext.runAsNonRoot` | Require container to run as non-root user | `undefined` | `true` |
| `securityContext.runAsUser` | User ID to run the container as | `undefined` | `1000` |

**Purpose**: Define security constraints at pod and container level:
- `podSecurityContext`: Pod-level security settings (file system permissions)
- `securityContext`: Container-level security (user, capabilities, read-only filesystem)

**Security Best Practices**:
```yaml
podSecurityContext:
  fsGroup: 2000

securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
```

### Service Configuration

```yaml
service:
  type: ClusterIP
  port: 3000
```

| Field | Purpose | Default | Values |
|-------|---------|---------|--------|
| `service.type` | Kubernetes service type (how to expose the app) | `ClusterIP` | `ClusterIP`, `NodePort`, `LoadBalancer` |
| `service.port` | Port number for the service | `3000` | Any valid port (1-65535) |

**Purpose**: Exposes the application to the network:
- `ClusterIP`: Internal access only (default, secure)
- `NodePort`: Access via node IP (for testing)
- `LoadBalancer`: Cloud load balancer (for production)

**Example - NodePort:**

```yaml
service:
  type: NodePort
  port: 80
```

### Gateway API HTTPRoute

```yaml
httpRoute:
  enabled: true
  annotations: {}
  hostnames: []
  parentRefs: []
  rules: []
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `httpRoute.enabled` | Enable Gateway API routing for external access | `true` | `false` |
| `httpRoute.annotations` | Kubernetes annotations for the HTTPRoute | `{}` | `{cert-manager.io/cluster-issuer: letsencrypt}` |
| `httpRoute.hostnames` | List of domain names to expose | `[]` | `["myapp.example.com", "api.example.com"]` |
| `httpRoute.parentRefs` | Reference to Gateway resource for routing | `[]` | See example below |
| `httpRoute.rules` | HTTPRoute matching and forwarding rules | `[]` | See example below |

**Purpose**: Uses Kubernetes Gateway API to expose the application externally (alternative to Ingress).

**Example**:
```yaml
httpRoute:
  enabled: true
  hostnames:
    - myapp.example.com
    - api.example.com
  parentRefs:
    - name: my-gateway
      namespace: default
      sectionName: http
  rules:
    - matches:
      - path:
          type: PathPrefix
          value: /
```

### Resource Requests and Limits

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `resources.requests.memory` | Minimum memory guaranteed to pod | `undefined` | `256Mi`, `1Gi` |
| `resources.requests.cpu` | Minimum CPU guaranteed to pod | `undefined` | `250m`, `1000m` |
| `resources.limits.memory` | Maximum memory allowed for pod | `undefined` | `512Mi`, `2Gi` |
| `resources.limits.cpu` | Maximum CPU allowed for pod | `undefined` | `500m`, `2000m` |

**Purpose**: Control pod resource usage:
- `requests`: Kubernetes reserves this amount for the pod; scheduler uses this to find nodes
- `limits`: Pod is killed if it exceeds these limits

**Key Differences**:
| Aspect | Requests | Limits |
|--------|----------|--------|
| Guarantee | Yes | No |
| Eviction | No | Yes (killed if exceeded) |
| Purpose | Scheduling | Protection |

**Recommended for production:**
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Health Checks

```yaml
livenessProbe:
  httpGet:
    path: /api/v1/health/live
    port: http

readinessProbe:
  httpGet:
    path: /api/v1/health/ready
    port: http
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `livenessProbe.httpGet.path` | Endpoint for liveness check | `/api/v1/health/live` | `/health`, `/status` |
| `livenessProbe.httpGet.port` | Port for liveness check | `http` (port 3000) | `8080`, `9000` |
| `readinessProbe.httpGet.path` | Endpoint for readiness check | `/api/v1/health/ready` | `/ready`, `/ping` |
| `readinessProbe.httpGet.port` | Port for readiness check | `http` (port 3000) | `8080`, `9000` |

**Purpose**: Monitor application health:

| Probe Type | Purpose | Action | Frequency |
|------------|---------|--------|-----------|
| **Liveness** | Detects if app is hung/dead | **Restarts** pod | Every 10s |
| **Readiness** | Detects if app is ready for traffic | **Removes** from service | Every 10s |
| **Startup** | Optional: Detects if app finished initializing | Waits before probes | Once |

**Differences**:
- **Liveness**: "Is the app alive?" → Restart if no
- **Readiness**: "Can I send traffic to this pod?" → Remove from load balancer if no

### Auto-scaling (HPA)

```yaml
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `autoscaling.enabled` | Enable/disable Horizontal Pod Autoscaler | `false` | `true` |
| `autoscaling.minReplicas` | Minimum number of pods | `1` | `2` |
| `autoscaling.maxReplicas` | Maximum number of pods | `100` | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU percentage to trigger scaling | `80` | `70` |

**Purpose**: Automatically scale application based on resource usage:
- `enabled`: Turn HPA on/off
- `minReplicas`: Never scale below this
- `maxReplicas`: Never scale above this
- `targetCPUUtilizationPercentage`: Scale up when CPU usage exceeds this

**How It Works**:
1. Current CPU < Target → Scale down (if above min)
2. Current CPU > Target → Scale up (if below max)

**Configuration for production**:
```yaml
autoscaling:
  enabled: true
  minReplicas: 2        # At least 2 replicas for HA
  maxReplicas: 10       # Prevent runaway scaling
  targetCPUUtilizationPercentage: 70
```

### Volumes and Volume Mounts

```yaml
volumes:
  - name: workastra-desk-configs
    configMap:
      name: "{{ include 'desk.fullname' . }}"
  - name: workastra-desk-secrets
    secret:
      secretName: "{{ include 'desk.fullname' . }}"
      optional: false

volumeMounts:
  - name: workastra-desk-configs
    mountPath: "/workastra-desk/configs"
    readOnly: true
  - name: workastra-desk-secrets
    mountPath: "/workastra-desk/secrets"
    readOnly: true
```

| Type | Volume Name | Source | Mount Path | Read-Only | Purpose |
|------|-------------|--------|-----------|-----------|---------|
| ConfigMap | `workastra-desk-configs` | ConfigMap `desk` | `/workastra-desk/configs` | Yes | Non-sensitive configuration files |
| Secret | `workastra-desk-secrets` | Secret `desk` | `/workastra-desk/secrets` | Yes | Sensitive data (API keys, passwords) |

**Volume vs VolumeMount**:
- `volumes`: Defines the data source (ConfigMap, Secret, disk, etc.)
- `volumeMounts`: Where to mount the volume inside the container

**Purpose**: Make configuration and secrets available to the application:
- **ConfigMaps**: Environment-specific configuration
- **Secrets**: Sensitive data (credentials, keys)
- **Read-Only**: Prevent accidental modification

### Node Scheduling

```yaml
nodeSelector: {}
tolerations: []
affinity: {}
```

| Field | Purpose | Default | Use Case |
|-------|---------|---------|----------|
| `nodeSelector` | Schedule pods on nodes with specific labels | `{}` | Schedule on SSD nodes, specific regions |
| `tolerations` | Allow scheduling on nodes with specific taints | `[]` | Schedule on tainted nodes (GPU, special hardware) |
| `affinity` | Advanced scheduling rules (pod affinity/anti-affinity) | `{}` | Spread pods across nodes, co-locate with other apps |

**Purpose**: Control where pods are scheduled in the cluster:

**nodeSelector - Simple Label-based Scheduling**:
```yaml
nodeSelector:
  disktype: ssd              # Schedule on nodes with label disktype=ssd
```

**tolerations - Work with Tainted Nodes**:
```yaml
tolerations:
  - key: gpu                 # Tolerate GPU taint
    operator: Equal
    value: "true"
    effect: NoSchedule
```

**affinity - Advanced Scheduling**:
```yaml
affinity:
  podAntiAffinity:           # Spread replicas across nodes
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - desk
          topologyKey: kubernetes.io/hostname
```

**Scheduling Hierarchy** (from simplest to most complex):
1. `nodeSelector`: Best for simple label-based scheduling
2. `tolerations`: Allow scheduling despite node taints
3. `affinity`: Best for complex requirements (pod spread, node groups, etc.)

### Secrets Configuration

```yaml
secrets:
  keys: []
  oauth2:
    clientSecret: ""
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `secrets.keys` | Application secret keys array | `[]` | `["key-2024", "key-2023"]` |
| `secrets.oauth2.clientSecret` | OAuth2 client secret | `""` | `abc123xyz` |

**Purpose**: Configure sensitive credentials for the application:

**secrets.keys**:
- First element is the current active key
- Additional elements are previous keys for rotation
- Used for session tokens, data encryption, etc.

**secrets.oauth2.clientSecret**:
- Secret for OAuth2 authentication
- Used when integrating with OAuth2 providers (Google, GitHub, etc.)

**Example**:
```yaml
secrets:
  keys:
    - "your-secret-key-2024"      # Currently active
    - "previous-secret-key-2023"  # Old key (for rotating)
  oauth2:
    clientSecret: "your-oauth2-secret"
```

**Key Rotation Best Practice**:
1. Add new key as first element
2. Keep old keys for backward compatibility
3. Remove oldest key after transition period

### Tenant Configuration

```yaml
tenant:
  scheme: http
  domain: workastra.com
```

| Field | Purpose | Default | Example |
|-------|---------|---------|---------|
| `tenant.scheme` | HTTP protocol to use | `http` | `http`, `https` |
| `tenant.domain` | Application domain/hostname | `workastra.com` | `myapp.example.com`, `api.mycompany.io` |

**Purpose**: Configure how the application is accessed from outside:
- `scheme`: Protocol for external URLs
- `domain`: Public domain name for the application

**Example**:
```yaml
tenant:
  scheme: https              # Use HTTPS
  domain: myapp.example.com  # Public domain
```

## Complete Example Values

```yaml
replicaCount: 3

image:
  repository: myregistry.azurecr.io/workastra-desk
  pullPolicy: Always
  tag: "v1.2.0"

imagePullSecrets:
  - name: registry-secret

serviceAccount:
  create: true
  name: desk-sa

podAnnotations:
  prometheus.io/scrape: "true"

service:
  type: ClusterIP
  port: 3000

httpRoute:
  enabled: true
  hostnames:
    - myapp.example.com
  parentRefs:
    - name: my-gateway
      namespace: default
      sectionName: http

resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 75

nodeSelector:
  disktype: ssd

secrets:
  keys:
    - "production-key"
  oauth2:
    clientSecret: "oauth-secret"

tenant:
  scheme: https
  domain: myapp.example.com
```

## Common Tasks

### Update Image Version

```bash
helm upgrade desk ./ \
  --set image.tag="v2.0.0"
```

### Scale Replicas

```bash
helm upgrade desk ./ \
  --set replicaCount=5
```

### Enable Auto-scaling

```bash
helm upgrade desk ./ \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=20
```

### Configure OAuth2

```bash
helm upgrade desk ./ \
  --set secrets.oauth2.clientSecret="new-secret"
```

### Set Resource Limits

```bash
helm upgrade desk ./ \
  --set resources.requests.memory="512Mi" \
  --set resources.limits.memory="1Gi"
```

## Templates

The chart includes these Kubernetes resource templates:

| Template | Resource Type | Description |
|----------|---------------|-------------|
| `deployment.yaml` | Deployment | Main application deployment |
| `service.yaml` | Service | Network service |
| `httproute.yaml` | HTTPRoute | Gateway API routing |
| `configmap.yaml` | ConfigMap | Configuration data |
| `secrets.yaml` | Secret | Sensitive data |
| `serviceaccount.yaml` | ServiceAccount | Kubernetes service account |
| `hpa.yaml` | HorizontalPodAutoscaler | Auto-scaling rules |
| `_helpers.tpl` | Template helpers | Helper functions |

## Troubleshooting

### Check Current Values

```bash
helm get values desk
```

### Render Templates

```bash
helm template desk ./
```

### Check Pod Status

```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check HTTPRoute

```bash
kubectl get httproute
kubectl describe httproute <httproute-name>
```

## See Also

- [Workastra Chart Documentation](../workastra/README.md) - Parent chart documentation
- [Main Repository README](../../README.md) - Quick start guide
