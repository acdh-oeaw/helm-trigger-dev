# Production Deployment Guide for Trigger.dev

This guide provides recommendations for deploying Trigger.dev in a production Kubernetes environment. Follow these best practices to ensure security, reliability, and performance.

## Table of Contents

- [Production Deployment Guide for Trigger.dev](#production-deployment-guide-for-triggerdev)
  - [Table of Contents](#table-of-contents)
  - [Security Recommendations](#security-recommendations)
    - [Database and Redis Credentials](#database-and-redis-credentials)
    - [TLS Configuration](#tls-configuration)
    - [Security Context](#security-context)
    - [Network Policies](#network-policies)
  - [Resource Management](#resource-management)
    - [Resource Allocation](#resource-allocation)
    - [Horizontal Pod Autoscaler](#horizontal-pod-autoscaler)
    - [Pod Disruption Budget](#pod-disruption-budget)
  - [Database Migration Configuration](#database-migration-configuration)
    - [Configuration Options](#configuration-options)
    - [Migration Strategy](#migration-strategy)
    - [Handling Long-Running Migrations](#handling-long-running-migrations)
  - [High Availability Configuration](#high-availability-configuration)
    - [Multi-replica Deployment](#multi-replica-deployment)
    - [Pod Anti-Affinity](#pod-anti-affinity)
    - [Topology Spread Constraints](#topology-spread-constraints)
  - [Monitoring and Logging](#monitoring-and-logging)
    - [Prometheus Integration](#prometheus-integration)
    - [Log Aggregation](#log-aggregation)
      - [Fluentd/Fluentbit Setup](#fluentdfluentbit-setup)
      - [ELK Stack Integration](#elk-stack-integration)
      - [Configuring Log Levels](#configuring-log-levels)
  - [Secret Management for Production Environments](#secret-management-for-production-environments)
    - [Overview](#overview)
    - [Best Practices](#best-practices)
    - [Implementation Guidance](#implementation-guidance)
  - [Authentication Methods for Production](#authentication-methods-for-production)
    - [Email Authentication](#email-authentication)
    - [GitHub OAuth](#github-oauth)
    - [Email Allowlist for Access Control](#email-allowlist-for-access-control)
  - [Immutable Deployments](#immutable-deployments)
  - [Registry Access in Production](#registry-access-in-production)
  - [Additional Production Settings](#additional-production-settings)
    - [Telemetry](#telemetry)
    - [Large Payloads](#large-payloads)
  - [Upgrading in Production](#upgrading-in-production)
    - [Pre-Upgrade Checklist](#pre-upgrade-checklist)
    - [Safe Upgrade Process](#safe-upgrade-process)
    - [Rollback Plan](#rollback-plan)
    - [Handling Database Migrations During Upgrades](#handling-database-migrations-during-upgrades)
  - [Conclusion](#conclusion)

## Security Recommendations

### Database and Redis Credentials

For production deployment, use Kubernetes secrets to store connection strings instead of putting them directly in values.yaml:

```bash
# Create a secret for database credentials
kubectl create secret generic trigger-db-secret \
  --namespace trigger-dev \
  --from-literal=DATABASE_URL="postgres://user:password@your-host:5432/postgres?sslmode=require" \
  --from-literal=DIRECT_URL="postgres://user:password@your-host:5432/postgres?sslmode=require"

# Create a secret for Redis credentials
kubectl create secret generic trigger-redis-secret \
  --namespace trigger-dev \
  --from-literal=REDIS_URL="redis://username:password@your-redis-host:port"
```

Then reference these secrets in your values.yaml:

```yaml
database:
  connectionStringSecret: "trigger-db-secret"

redis:
  secretName: "trigger-redis-secret"
```

### TLS Configuration

Always enable TLS for ingress in production environments:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: trigger.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: trigger-tls
      hosts:
        - trigger.example.com
```

### Security Context

For production, enable stricter security contexts:

```yaml
podSecurityContext:
  fsGroup: 1000
  runAsUser: 1000
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault

securityContext:
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
```

### Network Policies

Enable network policies to restrict pod communications:

```yaml
networkPolicy:
  enabled: true
```

## Resource Management

### Resource Allocation

Set appropriate resource requests and limits:

```yaml
resources:
  app:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      memory: 1Gi
  worker:
    requests:
      cpu: 300m
      memory: 512Mi
    limits:
      memory: 1.5Gi
  supervisor:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      memory: 1Gi
  dbMigration:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      memory: 256Mi
```

### Horizontal Pod Autoscaler

Enable autoscaling for higher availability:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

### Pod Disruption Budget

Ensure availability during cluster maintenance:

```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

## Database Migration Configuration

In production environments, database migrations require careful handling to prevent service disruption. The Helm chart includes a dedicated job for running Prisma migrations.

### Configuration Options

```yaml
dbMigration:
  # Enable the migration job
  enabled: true
  
  # Configure retries for failed migrations
  backoffLimit: 3
  
  # Set an appropriate timeout (in seconds)
  timeout: 600
  
  # Delete the job after completion (recommended for production)
  ttlSecondsAfterFinished: 3600
  
  # Use production environment for migration
  nodeEnv: "production"
  
  # Resource configuration for the migration job
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      memory: 512Mi
```

### Migration Strategy

For production deployments, consider the following migration strategy:

1. **Backup database** before migrations
2. **Schedule migrations** during low-traffic periods
3. **Test migrations** on a staging environment that mirrors production
4. **Monitor the migration job** closely:
   ```bash
   kubectl logs job/trigger-dev-migrations -n your-namespace
   ```
5. **Have a rollback plan** in case of migration failures

### Handling Long-Running Migrations

For schemas with large amounts of data, migrations might be slow. Consider:

```yaml
dbMigration:
  # Increase timeout for large databases
  timeout: 3600  # 1 hour
  
  # Add resource limits to prevent memory issues
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      memory: 1Gi
```

## High Availability Configuration

### Multi-replica Deployment

Set multiple replicas for redundancy:

```yaml
app:
  replicas: 2

worker:
  replicas: 2

supervisor:
  replicas: 2
```

### Pod Anti-Affinity

Distribute pods across nodes for higher availability:

```yaml
app:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: app.kubernetes.io/component
                  operator: In
                  values:
                    - app
            topologyKey: kubernetes.io/hostname
```

### Topology Spread Constraints

Ensure pods are distributed across failure domains:

```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: trigger-dev
```

## Monitoring and Logging

### Prometheus Integration

Trigger.dev exposes metrics that can be collected by Prometheus for monitoring. Here's a comprehensive setup:

```yaml
app:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "3000"
    prometheus.io/path: "/metrics"

worker:
  podAnnotations:
    prometheus.io/scrape: "true" 
    prometheus.io/port: "3000"
    prometheus.io/path: "/metrics"

supervisor:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8020"  # Note different port for supervisor
    prometheus.io/path: "/metrics"
```

For a full Prometheus stack with Grafana, you can deploy using the kube-prometheus-stack Helm chart:

```bash
# Add the Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install the Prometheus stack with Grafana
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

Key metrics to monitor include:
- HTTP request rates, errors, and durations
- Job execution counts and durations
- Worker queue lengths
- Database connection pool utilization
- Redis operation latencies

### Log Aggregation

For comprehensive logging in production, consider using a log aggregation solution:

#### Fluentd/Fluentbit Setup

```yaml
# Enable log collection for all components
app:
  podAnnotations:
    fluentd.io/collect: "true"
    logging: "json"  # Use structured logging

worker:
  podAnnotations:
    fluentd.io/collect: "true"
    logging: "json"

supervisor:
  podAnnotations:
    fluentd.io/collect: "true"
    logging: "json"
```

#### ELK Stack Integration

For deployments using the Elastic stack (Elasticsearch, Logstash, Kibana):

```yaml
# Configure filebeat sidecar for all components
app:
  podAnnotations:
    co.elastic.logs/enabled: "true"
    co.elastic.logs/json.keys_under_root: "true"
    co.elastic.logs/json.add_error_key: "true"

# Apply similar annotations to worker and supervisor components
```

#### Configuring Log Levels

Adjust logging verbosity for each component:

```yaml
app:
  env:
    LOG_LEVEL: "info"  # Options: debug, info, warn, error

worker:
  env:
    LOG_LEVEL: "info"

supervisor:
  env:
    LOG_LEVEL: "info"
```

For production, `info` level is recommended for normal operation, while `debug` can be temporarily enabled for troubleshooting.

## Secret Management for Production Environments

### Overview

The Trigger.dev Helm chart provides a `quickstart` mode that automatically generates secure secrets for testing and development. However, for production environments, it's recommended to implement proper secret management strategies.

### Best Practices

1. **Use External Secret Management Solutions**:
   - [Kubernetes External Secrets](https://github.com/external-secrets/external-secrets) to integrate with external secret stores
   - [HashiCorp Vault](https://www.vaultproject.io/) for secure secret storage and rotation
   - [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [GCP Secret Manager](https://cloud.google.com/secret-manager) for cloud-native deployments

2. **Implement Secret Rotation**:
   - Regularly rotate all sensitive credentials
   - Use short-lived service tokens when possible
   - The chart includes a placeholder `secretRotation` configuration for implementing custom rotation mechanisms

3. **Proper Credential Handling**:
   - Use connection string secrets for database and Redis credentials
   - Set up the database with minimal required permissions
   - Enable TLS for all external connections

### Implementation Guidance

To use external secrets with this chart:

1. Create secrets in your external secret store
2. Set `quickstart.enabled` to `false`
3. Configure `database.connectionStringSecret` and/or `redis.secretName` to reference Kubernetes secrets managed by your external secret solution
4. Provide all required environment variables as Kubernetes secrets

Example using External Secrets Operator:
```yaml
# ExternalSecret resource example
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: trigger-db-secret
spec:
  refreshInterval: "15m"
  secretStoreRef:
    name: vault-backend
    kind: SecretStore
  target:
    name: trigger-dev-db-creds
  data:
  - secretKey: DATABASE_URL
    remoteRef:
      key: path/to/secret
      property: db_url
  - secretKey: DIRECT_URL
    remoteRef:
      key: path/to/secret
      property: db_direct_url

# In Helm values.yaml
quickstart:
  enabled: false

database:
  connectionStringSecret: "trigger-dev-db-creds"
```

## Authentication Methods for Production

### Email Authentication

For production environments, configure SMTP settings with proper secret management:

```bash
# Create a secret for SMTP credentials
kubectl create secret generic trigger-smtp-creds \
  --namespace your-trigger-namespace \
  --from-literal=SMTP_PASSWORD=your-smtp-password
```

Then reference it in your values:
```yaml
app:
  env:
    # SMTP settings for sending magic link emails
    SMTP_HOST: "smtp.example.com"
    SMTP_PORT: "587"
    SMTP_USER: "trigger-notifications@example.com"
    SMTP_PASSWORD:
      valueFrom:
        secretKeyRef:
          name: trigger-smtp-creds
          key: SMTP_PASSWORD
    SMTP_SECURE: "true"
    SMTP_FROM_ADDRESS: "no-reply@example.com"
    SMTP_REPLY_TO: "support@example.com"
```

### GitHub OAuth

For secure GitHub authentication in production environments:
```bash
kubectl create secret generic trigger-github-oauth \
  --namespace your-trigger-namespace \
  --from-literal=AUTH_GITHUB_CLIENT_ID=your-client-id \
  --from-literal=AUTH_GITHUB_CLIENT_SECRET=your-client-secret
```

Then reference in your values:
```yaml
app:
  env:
    AUTH_GITHUB_CLIENT_ID:
      valueFrom:
        secretKeyRef:
          name: trigger-github-oauth
          key: AUTH_GITHUB_CLIENT_ID
    AUTH_GITHUB_CLIENT_SECRET:
      valueFrom:
        secretKeyRef:
          name: trigger-github-oauth
          key: AUTH_GITHUB_CLIENT_SECRET
```

### Email Allowlist for Access Control

Restrict which email addresses can register using a regex pattern:
```yaml
app:
  env:
    WHITELISTED_EMAILS: ".*@your-company\\.com"
```

## Immutable Deployments

For improved stability and rollback capabilities in production:

Use image digests instead of tags for deterministic deployments:

```yaml
image:
  repository: ghcr.io/triggerdotdev/trigger.dev
  digest: "sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  tag: "" # Not used when digest is specified

supervisorImage:
  repository: ghcr.io/triggerdotdev/supervisor
  digest: "sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  tag: "" # Not used when digest is specified
  
coordinatorImage:
  repository: ghcr.io/triggerdotdev/coordinator
  digest: "sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  tag: "" # Not used when digest is specified
  
kubernetesProviderImage:
  repository: ghcr.io/triggerdotdev/provider/kubernetes
  digest: "sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
  tag: "" # Not used when digest is specified
```

## Registry Access in Production

For secure Docker registry access in production environments:

1. Create a Kubernetes secret with registry credentials using a CI/CD pipeline or secure secret management:
   ```bash
   kubectl create secret docker-registry regcred \
     --namespace your-trigger-namespace \
     --docker-server=docker.io \
     --docker-username=your-username \
     --docker-password=your-registry-token \
     --docker-email=your-email@example.com
   ```

2. Reference this secret in your values.yaml and ensure it's never committed to version control:
   ```yaml
   imagePullSecrets:
     - name: regcred
   ```

3. Configure service accounts with proper IAM roles for cloud provider registries:
   ```yaml
   serviceAccount:
     create: true
     annotations:
       # Example for AWS ECR
       eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/ecr-access-role
       # Example for GCR
       iam.gke.io/gcp-service-account: trigger-dev@your-project.iam.gserviceaccount.com
   ```

## Additional Production Settings

### Telemetry

Trigger.dev collects anonymous usage data by default to help improve the product. This telemetry is sent to the Trigger.dev team and is separate from your own logging and metrics collection.

For organizations with strict data policies, you can disable this telemetry:

```yaml
app:
  env:
    TRIGGER_TELEMETRY_DISABLED: "1"
```

**Important**: Disabling telemetry only stops sending usage data to Trigger.dev. It does not affect your own logging, metrics collection, or the application's functionality. You should still configure proper logging and metrics as described in the [Monitoring and Logging](#monitoring-and-logging) section.

### Large Payloads

For production environments handling large payloads, adjust settings:

```yaml
app:
  env:
    # Increase maximum payload size (default 5MB)
    MAX_PAYLOAD_SIZE_MB: "20"
```

## Upgrading in Production

Upgrading Trigger.dev in a production environment requires careful planning to minimize downtime and prevent data loss.

### Pre-Upgrade Checklist

Before upgrading your production deployment, complete this checklist:

1. **Backup your database**:
   ```bash
   # For Neon or other PostgreSQL databases
   pg_dump -h your-db-host -U your-username -d your-database > trigger_backup_$(date +%Y%m%d).sql
   ```

2. **Review the changelog**:
   - Check for breaking changes in new versions
   - Verify compatibility with your existing configuration
   - Note any required manual migration steps

3. **Test the upgrade in staging**:
   - Maintain a staging environment that mirrors production
   - Apply the upgrade in staging first
   - Verify all functionality works as expected

### Safe Upgrade Process

Follow this process for a safe upgrade:

1. **Update your values file**:
   ```yaml
   # Update image versions
   image:
     tag: "3.3.19"  # New version
   
   supervisorImage:
     tag: "3.3.19"  # New version
   
   coordinatorImage:
     tag: "3.3.19"  # New version
   
   kubernetesProviderImage:
     tag: "3.3.19"  # New version
   ```

2. **Use Helm diff to preview changes**:
   ```bash
   # Preview changes before applying
   helm diff upgrade trigger-dev . \
     --values production-values.yaml \
     --namespace your-trigger-namespace
   ```

3. **Apply the upgrade with proper deployment strategy**:
   ```bash
   # Apply the upgrade
   helm upgrade trigger-dev . \
     --values production-values.yaml \
     --namespace your-trigger-namespace \
     --atomic  # Rolls back on failure
   ```

4. **Monitor the deployment**:
   ```bash
   # Watch pods during rollout
   kubectl get pods -n your-trigger-namespace -w
   
   # Check application logs
   kubectl logs -l app.kubernetes.io/component=app -n your-trigger-namespace
   ```

### Rollback Plan

Always have a rollback plan ready in case of failures:

```bash
# Roll back to the previous release
helm rollback trigger-dev 1 -n your-trigger-namespace

# Verify rollback succeeded
kubectl get pods -n your-trigger-namespace
```

### Handling Database Migrations During Upgrades

Database migrations require special attention during upgrades:

1. **Review the migration job logs**:
   ```bash
   kubectl logs job/trigger-dev-migrations -n your-trigger-namespace
   ```

2. **For complex migrations, consider running migrations separately**:
   ```bash
   # First apply migrations only
   helm upgrade trigger-dev . \
     --values production-values.yaml \
     --set app.enabled=false \
     --set worker.enabled=false \
     --set supervisor.enabled=false \
     --set dbMigration.enabled=true \
     --namespace your-trigger-namespace
   
   # Then apply the full upgrade after migrations complete
   helm upgrade trigger-dev . \
     --values production-values.yaml \
     --namespace your-trigger-namespace
   ```

## Conclusion

Following these best practices will help ensure a secure, reliable, and performant Trigger.dev deployment in production environments. Remember to tune these recommendations to your specific requirements and workload characteristics. 