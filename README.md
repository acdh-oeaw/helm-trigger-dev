# Trigger.dev Helm Chart

This Helm chart deploys [Trigger.dev](https://trigger.dev/) - an open-source platform for creating event-driven background tasks and workflows - to a Kubernetes cluster.

> **Note**: This is a community-maintained chart for Kubernetes deployment of Trigger.dev v3.3.x.

## Version Compatibility

| Trigger.dev Version | Chart Version | Kubernetes Version |
|-------------------|---------------|-------------------|
| 3.3.x             | 3.3.18        | 1.19+            |

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- External PostgreSQL database (e.g., [Neon](https://neon.tech/))
- External Redis instance (e.g., [Upstash](https://upstash.com/))

## Quick Installation

### 1. Add the Helm repository

```bash
helm repo add trigger-dev https://hongkongkiwi.github.io/helm-trigger-dev
helm repo update
```

### 2. Create your values file

Choose the appropriate values file based on your environment:

#### For Development/Testing
Use the default `values.yaml` for development and testing. This provides a minimal configuration:

```yaml
# Database settings
database:
  externalHost: "your-db-host.neon.tech"
  externalPort: 5432
  externalDatabase: "postgres"
  externalUser: "postgres" 
  externalPassword: "your-db-password"

# Redis settings
redis:
  url: "redis://username:password@your-redis-host:port"

# Application URL settings (for webhooks)
app:
  env:
    TRIGGER_PROTOCOL: "https"  # or http for development
    TRIGGER_DOMAIN: "trigger.your-domain.com"
```

#### For Production
Use `values-production.yaml` which includes production-grade settings:

```bash
# Install with production values
helm install trigger-dev trigger-dev/trigger-dev -f values-production.yaml --namespace trigger-dev --create-namespace
```

Key production features:
- Enhanced security (seccomp profiles, read-only filesystems)
- High availability (multiple replicas, pod disruption budgets)
- Production-grade resource limits
- TLS and ingress with best practices
- Secret management for sensitive data
- Autoscaling configuration
- Topology spread constraints

> **Note**: Before deploying to production, review and customize `values-production.yaml` to match your specific requirements. See [PRODUCTION.md](./PRODUCTION.md) for detailed guidelines.

### 3. Install the chart

```bash
helm install trigger-dev trigger-dev/trigger-dev --values values.yaml --namespace trigger-dev --create-namespace
```

### 4. Access Trigger.dev

For quick testing, use port forwarding:

```bash
kubectl port-forward svc/trigger-dev-app 3000:3000 -n trigger-dev
```

Then visit http://localhost:3000 in your browser.

For production, configure an ingress:

```yaml
ingress:
  enabled: true
  hosts:
    - host: trigger.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: trigger-tls
      hosts:
        - trigger.your-domain.com
```

## Using with the CLI

Connect your CLI to your self-hosted instance:

```bash
# Install the CLI
npm install -g trigger.dev

# Login to your instance
npx trigger.dev@latest login -a https://trigger.your-domain.com

# Create a new project
npx trigger.dev@latest init
```

## Essential Configuration

### Email Authentication

Enable magic link email authentication:

```yaml
app:
  env:
    SMTP_HOST: "smtp.example.com"
    SMTP_PORT: "587"
    SMTP_USER: "your-smtp-user"
    SMTP_PASSWORD: "your-smtp-password"
    SMTP_SECURE: "true"
    SMTP_FROM_ADDRESS: "no-reply@example.com"
```

### Restricting Access

Limit registration to specific email domains:

```yaml
app:
  env:
    WHITELISTED_EMAILS: ".*@your-company\\.com"
```

### Docker Registry Access

For deploying v3 projects, set up registry access:

```bash
# Create registry credentials
kubectl create secret docker-registry regcred \
  --namespace trigger-dev \
  --docker-server=docker.io \
  --docker-username=your-username \
  --docker-password=your-registry-token \
  --docker-email=your-email@example.com

# Reference in values.yaml
imagePullSecrets:
  - name: regcred

app:
  env:
    DEPLOY_REGISTRY_HOST: "docker.io"
    DEPLOY_REGISTRY_NAMESPACE: "your-registry-namespace"
```

## Upgrading

```bash
helm upgrade trigger-dev trigger-dev/trigger-dev --values values.yaml --namespace trigger-dev
```

## Uninstalling

```bash
helm uninstall trigger-dev --namespace trigger-dev
```

## Components Overview

The chart deploys:

- **Web App**: Frontend interface and API
- **Worker**: Background job processing
- **Supervisor**: Task execution coordination
- **Database Migration**: Sets up the database schema

For detailed information about the system architecture and component interactions, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Template Structure

### External Dependencies

This chart deploys stateless applications that rely on external services:

#### Required External Services
1. **Database**
   - External PostgreSQL instance (e.g., Neon.tech)
   - Configured via connection string in values.yaml
   - Used for persistent data storage

2. **Redis**
   - External Redis instance
   - Configured via connection string in values.yaml
   - Used for job queue and caching

3. **File Storage**
   - All file storage is handled by external services
   - No local volumes required

### Architecture Notes
- All components are stateless and can be scaled horizontally
- No persistent volumes are required
- External services are configured via connection strings in values.yaml
- Database migrations are handled via one-time jobs

### Directory Structure

- `app/` - Main application components
  - `deployment.yaml` - Main application deployment
  - `service.yaml` - Application service
  - `configmap.yaml` - Non-sensitive configuration
  - `hpa.yaml` - Horizontal Pod Autoscaling
  - `pdb.yaml` - Pod Disruption Budget

- `worker/` - Background worker components
  - `deployment.yaml` - Worker deployment

- `supervisor/` - Supervisor service components
  - `deployment.yaml` - Supervisor deployment
  - `service.yaml` - Supervisor service

- `database/` - Database-related components
  - `db-migrate-job.yaml` - Database migration job

- `networking/` - Network-related components
  - `ingress.yaml` - Ingress configuration
  - `network-policy.yaml` - Network policies

- `security/` - Security-related components
  - `rbac.yaml` - Role-Based Access Control
  - `serviceaccount.yaml` - Service account definitions

### Common Templates

- `_helpers.tpl` - Common template helpers and functions
- `_quickstart.tpl` - Quickstart guide template
- `NOTES.txt` - Post-installation notes

### Best Practices

1. All templates should use the common labels defined in `_helpers.tpl`
2. Sensitive data should be stored in Kubernetes secrets
3. Non-sensitive configuration should use ConfigMaps
4. Use conditional rendering with `if` statements for optional components
5. Follow Kubernetes naming conventions and best practices

## Troubleshooting

### Common Issues

#### Database Connection Issues
- Check database credentials and firewall settings
- Verify SSL mode configuration
- Ensure database is accessible from Kubernetes cluster
- Check database connection pool settings

#### Pod Startup Failures
- Check pod logs: `kubectl logs -n trigger-dev <pod-name>`
- Verify resource limits and requests
- Check for missing secrets or configmaps
- Verify image pull policy and registry access

#### Authentication Problems
- Verify SMTP settings for email authentication
- Check OAuth configuration if using GitHub login
- Verify email allowlist settings
- Check session storage configuration

#### Task Execution Issues
- Check supervisor logs for scheduling problems
- Verify worker pod logs for execution errors
- Check Redis connection and queue status
- Verify Docker registry access for v3 projects

### Debugging Steps

1. **Check Pod Status**
   ```bash
   kubectl get pods -n trigger-dev
   kubectl describe pod <pod-name> -n trigger-dev
   ```

2. **View Component Logs**
   ```bash
   # App logs
   kubectl logs -l app.kubernetes.io/component=app -n trigger-dev
   
   # Worker logs
   kubectl logs -l app.kubernetes.io/component=worker -n trigger-dev
   
   # Supervisor logs
   kubectl logs -l app.kubernetes.io/component=supervisor -n trigger-dev
   ```

3. **Verify Configuration**
   ```bash
   # Check ConfigMaps
   kubectl get configmaps -n trigger-dev
   
   # Check Secrets
   kubectl get secrets -n trigger-dev
   ```

4. **Database Connectivity**
   ```bash
   # Test database connection from a pod
   kubectl exec -it <pod-name> -n trigger-dev -- psql $DATABASE_URL
   ```

5. **Redis Connectivity**
   ```bash
   # Test Redis connection from a pod
   kubectl exec -it <pod-name> -n trigger-dev -- redis-cli -u $REDIS_URL ping
   ```

### Get Help

- Join the [Trigger.dev Discord](https://trigger.dev/discord) for community support
- Check the [Trigger.dev documentation](https://trigger.dev/docs)
- Review the [PRODUCTION.md](./PRODUCTION.md) guide for production-specific issues
- Check the [ARCHITECTURE.md](./ARCHITECTURE.md) for system design details

---

## Detailed Reference

For more detailed information about:

- Production best practices and advanced configuration
- System architecture and component details
- High availability setups
- Security considerations
- Resource management
- Authentication methods

See the following documentation:
- [PRODUCTION.md](./PRODUCTION.md) - Production deployment guide
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture and components
- [Trigger.dev documentation](https://trigger.dev/docs/documentation/introduction) - Official documentation