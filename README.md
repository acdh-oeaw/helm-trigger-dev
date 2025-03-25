# Trigger.dev Helm Chart

This Helm chart deploys [Trigger.dev](https://trigger.dev/) - an open-source platform for creating event-driven background tasks and workflows with your codebase - to a Kubernetes cluster.

> **Note**: This is not an official Trigger.dev Helm chart. It was created to address the lack of available Kubernetes deployment resources for Trigger.dev. The motivation behind developing this chart was to enable self-hosting on Kubernetes when official self-hosted runners were not available. This community-maintained chart aims to make Trigger.dev deployment on Kubernetes more accessible.

## Chart Version

This chart is currently at version 3.3.18 and supports Trigger.dev version 3.3.x.

## Key Details

- **Container Images**: This chart uses [GitHub Container Registry](https://ghcr.io) (ghcr.io):
  - `ghcr.io/triggerdotdev/trigger.dev` - Main application for app/worker
  - `ghcr.io/triggerdotdev/coordinator` - Coordinator mode supervisor
  - `ghcr.io/triggerdotdev/provider/kubernetes` - Kubernetes provider
  - `ghcr.io/triggerdotdev/supervisor` - Supervisor for "both" mode
- **Resources**: Minimum recommended 4 vCPU, 8GB RAM for production
- **Prerequisites**: 
  - Kubernetes 1.19+
  - Helm 3.2.0+
  - External PostgreSQL database
  - External Redis instance
- **Support**: [Self-hosting Discord channel](https://trigger.dev/discord)

## Table of Contents

- [Trigger.dev Helm Chart](#triggerdev-helm-chart)
  - [Chart Version](#chart-version)
  - [Key Details](#key-details)
  - [Table of Contents](#table-of-contents)
  - [Quick Start Guide](#quick-start-guide)
    - [What You're Deploying](#what-youre-deploying)
    - [1. Prerequisites](#1-prerequisites)
    - [2. Add the Helm repository and update](#2-add-the-helm-repository-and-update)
    - [3. Configure Your Values File](#3-configure-your-values-file)
    - [4. Install the Chart](#4-install-the-chart)
    - [5. Access Trigger.dev](#5-access-triggerdev)
    - [6. Next Steps](#6-next-steps)
    - [7. Using the CLI with Your Self-Hosted Instance](#7-using-the-cli-with-your-self-hosted-instance)
  - [Installation and Management](#installation-and-management)
    - [Installing the Chart](#installing-the-chart)
    - [Upgrading the Chart](#upgrading-the-chart)
    - [Uninstalling the Chart](#uninstalling-the-chart)
    - [Verifying Installation](#verifying-installation)
    - [Creating and Managing Values Files](#creating-and-managing-values-files)
  - [Architecture](#architecture)
    - [Components Overview](#components-overview)
    - [Web Application (App)](#web-application-app)
    - [Worker](#worker)
    - [Supervisor](#supervisor)
      - [Coordinator](#coordinator)
      - [Kubernetes Provider](#kubernetes-provider)
    - [Database Migration](#database-migration)
  - [Configuration](#configuration)
    - [Horizontal Pod Autoscaler](#horizontal-pod-autoscaler)
    - [Pod Disruption Budget](#pod-disruption-budget)
    - [Network Policy](#network-policy)
    - [RBAC for Kubernetes Provider](#rbac-for-kubernetes-provider)
  - [External Services](#external-services)
    - [Neon PostgreSQL](#neon-postgresql)
    - [Upstash Redis](#upstash-redis)
  - [Security](#security)
    - [Pod Security Context](#pod-security-context)
    - [Security Context](#security-context)
  - [Integrations](#integrations)
    - [External DNS](#external-dns)
    - [Certificate Management](#certificate-management)
  - [Production Best Practices](#production-best-practices)
    - [Resource Management](#resource-management)
    - [High Availability](#high-availability)
    - [Immutable Deployments](#immutable-deployments)
  - [Secret Management for Production Environments](#secret-management-for-production-environments)
    - [For detailed information on managing secrets in production environments, please refer to the [PRODUCTION.md](./PRODUCTION.md) file. Key topics covered include:
      - Using external secret management solutions
      - Implementing secret rotation
      - Proper credential handling with Kubernetes secrets
      - Implementation examples with various secret management tools

    For telemetry settings, registry access configuration, and authentication method setup in production, also see [PRODUCTION.md](./PRODUCTION.md).
  - [Telemetry](#telemetry)
  - [Docker Registry Access](#docker-registry-access)
    - [Harbor Registry Configuration](#harbor-registry-configuration)
  - [Authentication Methods](#authentication-methods)
    - [Magic Link Email (Recommended)](#magic-link-email-recommended)
    - [GitHub OAuth](#github-oauth)
    - [Email Allowlist for Access Control](#email-allowlist-for-access-control)
  - [Deployment Configuration](#deployment-configuration)
    - [Registry Configuration](#registry-configuration)
    - [Checkpoint Support (Not Currently Supported in Kubernetes)](#checkpoint-support-not-currently-supported-in-kubernetes)
    - [Custom CLI Configuration](#custom-cli-configuration)
    - [Large Payloads](#large-payloads)
  - [Self-Hosting Considerations](#self-hosting-considerations)
    - [System Requirements](#system-requirements)
      - [Architecture Compatibility](#architecture-compatibility)
    - [Additional Environment Variables](#additional-environment-variables)
    - [Security Caveats](#security-caveats)
    - [Scaling Considerations](#scaling-considerations)
  - [Docker vs. Kubernetes Deployment](#docker-vs-kubernetes-deployment)
  - [Troubleshooting](#troubleshooting)
    - [Diagnosing Issues](#diagnosing-issues)
    - [Helm Chart Configuration Debugging](#helm-chart-configuration-debugging)
    - [Common Issues \& FAQs](#common-issues--faqs)
      - ["I can't connect to the database"](#i-cant-connect-to-the-database)
      - ["Pods are failing to start"](#pods-are-failing-to-start)
      - ["How do I set up email authentication?"](#how-do-i-set-up-email-authentication)
      - ["Tasks are not executing"](#tasks-are-not-executing)
      - ["I'm getting errors with the CLI and my self-hosted instance"](#im-getting-errors-with-the-cli-and-my-self-hosted-instance)
  - [Conclusion and Next Steps](#conclusion-and-next-steps)

## Quick Start Guide

Follow these steps to get Trigger.dev up and running on your Kubernetes cluster in minutes. This guide is designed for those who want to quickly deploy Trigger.dev with minimal configuration. For production deployments, refer to the [Configuration](#configuration) and [Production Best Practices](#production-best-practices) sections.

### What You're Deploying

This Helm chart sets up the following components in your Kubernetes cluster:

```
                                 ┌───────────────────┐
                                 │                   │
                                 │  Your Application │
                                 │     with SDK      │
                                 │                   │
                                 └─────────┬─────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                         Kubernetes Cluster                          │
│                                                                     │
│   ┌─────────────┐      ┌─────────────┐      ┌─────────────────┐    │
│   │             │      │             │      │                 │    │
│   │  Trigger.dev│      │  Trigger.dev│      │   Trigger.dev   │    │
│   │     App     │◄────►│    Worker   │◄────►│    Supervisor   │    │
│   │  (Frontend) │      │ (Background)│      │  (Coordinator)  │    │
│   │             │      │             │      │                 │    │
│   └──────┬──────┘      └─────────────┘      └────────┬────────┘    │
│          │                                           │              │
└──────────┼───────────────────────────────────────────┼──────────────┘
           │                                           │
           ▼                                           ▼
 ┌───────────────────┐                       ┌──────────────────┐
 │                   │                       │                  │
 │     Database      │                       │      Redis       │
 │   (PostgreSQL)    │                       │                  │
 │                   │                       │                  │
 └───────────────────┘                       └──────────────────┘
      External                                    External
```

### 1. Prerequisites

Make sure you have:
- A Kubernetes cluster (v1.19+)
- Helm 3.2.0+ installed 
- An external PostgreSQL database ([Neon](https://neon.tech/) recommended)
- An external Redis instance ([Upstash](https://upstash.com/) recommended)

### 2. Add the Helm repository and update

```bash
# Clone this repository
git clone https://github.com/hongkongkiwi/helm-trigger-dev.git
cd helm-trigger-dev
```

Alternatively, you can add the repository using Helm:

```bash
# Add the Helm repository
helm repo add trigger-dev https://hongkongkiwi.github.io/helm-trigger-dev
helm repo update
```

### 3. Configure Your Values File

Create a `my-values.yaml` file with your database and Redis credentials:

```yaml
# Database settings
database:
  externalHost: "your-db-host.neon.tech"  # Replace with your database host
  externalPort: 5432
  externalDatabase: "postgres"
  externalUser: "postgres" 
  externalPassword: "your-db-password"  # Replace with your database password

# Redis settings
redis:
  url: "redis://username:password@your-redis-host:port"  # Replace with your Redis URL
```

For a more complete setup, here's a minimal production-ready example:

```yaml
# Namespace settings
createNamespace: true
namespace: "trigger-dev"

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

# Ingress configuration
ingress:
  enabled: true
  className: "nginx"  # Use your ingress class
  annotations:
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: trigger.your-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: trigger-tls
      hosts:
        - trigger.your-domain.com

# Application settings
app:
  env:
    # Required for proper URL generation
    TRIGGER_PROTOCOL: "https"
    TRIGGER_DOMAIN: "trigger.your-domain.com"
    
    # Email authentication (optional but recommended)
    SMTP_HOST: "smtp.example.com"
    SMTP_PORT: "587"
    SMTP_USER: "your-smtp-user"
    SMTP_PASSWORD: "your-smtp-password"
    SMTP_SECURE: "true"
    SMTP_FROM_ADDRESS: "no-reply@example.com"
    
    # Restrict access to specific email domains (optional)
    WHITELISTED_EMAILS: ".*@your-company\\.com"
```

### 4. Install the Chart

```bash
helm install trigger ./trigger-dev --values my-values.yaml
```

### 5. Access Trigger.dev

By default, the chart doesn't create an Ingress. You can:

a) Set up port forwarding to access the UI:
```bash
kubectl port-forward svc/trigger-dev-app 3000:3000
```
Then visit http://localhost:3000 in your browser

b) Or enable and configure an Ingress in your values file:
```yaml
ingress:
  enabled: true
  hosts:
    - host: trigger.your-domain.com
      paths:
        - path: /
          pathType: Prefix
```

### 6. Next Steps

- Create an account in the Trigger.dev dashboard
- Get your API key from the dashboard
- Connect your application using the Trigger.dev SDK

### 7. Using the CLI with Your Self-Hosted Instance

Once your Trigger.dev instance is running, connect using the CLI:

```bash
# Install the CLI (if you haven't already)
npm install -g trigger.dev

# Login to your instance (replace with your actual URL)
npx trigger.dev@latest login -a https://trigger.your-domain.com

# Create a new project 
npx trigger.dev@latest init
```

## Installation and Management

### Installing the Chart

To install the Trigger.dev Helm chart:

```bash
# From the cloned repository
git clone https://github.com/hongkongkiwi/helm-trigger-dev.git
cd helm-trigger-dev

# Install with a values file
helm install trigger-dev . --values your-values.yaml --namespace your-namespace

# Or install with specific overrides
helm install trigger-dev . \
  --set database.externalHost=your-db-host.neon.tech \
  --set database.externalUser=postgres \
  --set database.externalPassword=your-password \
  --set redis.url=redis://username:password@your-redis-host:port \
  --set app.env.TRIGGER_PROTOCOL=https \
  --set app.env.TRIGGER_DOMAIN=trigger.example.com \
  --namespace your-namespace
```

If you added the Helm repository:

```bash
# Install using the Helm repository
helm install trigger-dev trigger-dev/trigger-dev \
  --version 3.3.18 \
  --values your-values.yaml \
  --namespace your-namespace
```

Alternatively, you can use the OCI registry to install the chart (if available):

```bash
# Using OCI registry
helm install trigger-dev oci://ghcr.io/hongkongkiwi/helm-trigger-dev/trigger-dev \
  --version 3.3.18 \
  --values your-values.yaml \
  --namespace your-namespace
```

You can also install directly from raw GitHub files without cloning the repository:

```bash
# Install directly from GitHub
helm install trigger-dev https://raw.githubusercontent.com/hongkongkiwi/helm-trigger-dev/main/helm/trigger-dev \
  --values your-values.yaml \
  --namespace your-namespace

# Or specify a specific version/tag
helm install trigger-dev https://raw.githubusercontent.com/hongkongkiwi/helm-trigger-dev/v3.3.18/helm/trigger-dev \
  --values your-values.yaml \
  --namespace your-namespace
```

### Upgrading the Chart

To upgrade your existing Trigger.dev installation:

```bash
# Update with a values file
helm upgrade trigger-dev . --values your-values.yaml --namespace your-namespace

# Or update with specific overrides
helm upgrade trigger-dev . \
  --set image.tag=3.3.19 \
  --set supervisorImage.tag=3.3.19 \
  --set coordinatorImage.tag=3.3.19 \
  --set kubernetesProviderImage.tag=3.3.19 \
  --namespace your-namespace
```

If you installed using the Helm repository:

```bash
# Upgrade using the Helm repository
helm upgrade trigger-dev trigger-dev/trigger-dev \
  --version 3.3.19 \
  --values your-values.yaml \
  --namespace your-namespace
```

If using the OCI registry:

```bash
# Upgrade from the OCI registry
helm upgrade trigger-dev oci://ghcr.io/hongkongkiwi/helm-trigger-dev/trigger-dev \
  --version 3.3.19 \
  --values your-values.yaml \
  --namespace your-namespace
```

You can also upgrade directly from raw GitHub files:

```bash
# Upgrade directly from GitHub raw files
helm upgrade trigger-dev https://raw.githubusercontent.com/hongkongkiwi/helm-trigger-dev/main/helm/trigger-dev \
  --values your-values.yaml \
  --namespace your-namespace

# Or specify a specific version/tag
helm upgrade trigger-dev https://raw.githubusercontent.com/hongkongkiwi/helm-trigger-dev/v3.3.19/helm/trigger-dev \
  --values your-values.yaml \
  --namespace your-namespace
```

**Important:** Always check the [changelog](https://github.com/hongkongkiwi/helm-trigger-dev/blob/main/CHANGELOG.md) for breaking changes before upgrading to a new version. Major version upgrades may require additional steps.

If you encounter issues during upgrades:

```bash
# Force resource updates (use with caution)
helm upgrade trigger-dev . --values your-values.yaml --force --namespace your-namespace

# Check upgrade history
helm history trigger-dev --namespace your-namespace

# Rollback to a previous release if needed
helm rollback trigger-dev 1 --namespace your-namespace
```

### Uninstalling the Chart

To uninstall/delete your `trigger-dev` deployment:

```bash
helm uninstall trigger-dev --namespace your-namespace
```

This removes all Kubernetes components associated with the chart but may leave Persistent Volume Claims (PVCs) and ConfigMaps which need to be manually removed:

```bash
# Remove PVCs (if you have persistent storage enabled)
kubectl delete pvc --selector=app.kubernetes.io/instance=trigger-dev -n your-namespace

# Remove ConfigMaps
kubectl delete configmap --selector=app.kubernetes.io/instance=trigger-dev -n your-namespace

# Remove Secrets
kubectl delete secret --selector=app.kubernetes.io/instance=trigger-dev -n your-namespace
```

If you've deployed using a custom namespace, you may want to remove the entire namespace:

```bash
kubectl delete namespace your-namespace
```

> ⚠️ **Warning**: This will delete all resources in the namespace, not just those created by Helm.

### Verifying Installation

After installing the chart, verify that your pods are running:

```bash
kubectl get pods --namespace your-namespace -l "app.kubernetes.io/instance=trigger-dev"
```

Check the status of all deployed components:

```bash
kubectl get deployment,statefulset,service,ingress,pvc,secret,configmap -l "app.kubernetes.io/instance=trigger-dev" -n your-namespace
```

Verify database migrations have completed by checking the logs of the migration job:

```bash
kubectl logs job/trigger-dev-migrations -n your-namespace
```

If configured correctly, you should be able to access the application at the URL specified in your values file.

To check the version information of your installed chart:

```bash
helm list -n your-namespace
```

For more detailed diagnostics, you can check the logs of the main application:

```bash
kubectl logs deployment/trigger-dev-app -n your-namespace
```

### Creating and Managing Values Files

For production deployments, it's best practice to create a dedicated values file:

1. Create a copy of the default values.yaml:

```bash
# Clone the repository if you haven't already
git clone https://github.com/hongkongkiwi/helm-trigger-dev.git
cd helm-trigger-dev

# Copy the default values file to create your custom values
cp values.yaml my-values.yaml
```

2. Edit the essential parameters in your my-values.yaml file:

```yaml
# Namespace settings
namespace: "trigger-dev"

# Database settings (required)
database:
  externalHost: "your-db-host.neon.tech"
  externalPort: 5432
  externalDatabase: "postgres"
  externalUser: "postgres"
  externalPassword: "your-db-password"

# Redis settings (required)
redis:
  url: "redis://username:password@your-redis-host:port"

# Application URL settings (required for webhooks and CLI integration)
app:
  env:
    TRIGGER_PROTOCOL: "https"
    TRIGGER_DOMAIN: "trigger.example.com"
```

3. Keep your values file in a secure location, possibly in a version-controlled repository with proper secrets management.

4. For upgrades, update the file and then use:

```bash
helm upgrade trigger-dev . --values my-values.yaml --namespace your-namespace
```

You can also use `--set` flags to override specific values without modifying your values file:

```bash
helm upgrade trigger-dev . \
  --values my-values.yaml \
  --set image.tag=3.3.20 \
  --namespace your-namespace
```

For more detailed configuration options, see the sections below.

## Architecture

### Components Overview

Trigger.dev consists of several key components that work together to deliver the full functionality of the platform:

- **Web Application (App)**: The frontend interface and API endpoints
- **Worker**: Handles background processing and job execution
- **Supervisor**: Coordinates task execution and manages providers
  - When in coordinator mode (default): Uses the coordinator image and API
  - When in provider mode: Uses the Kubernetes provider image
  - When in both mode: Uses the supervisor image for combined functionality
- **Database**: PostgreSQL for storing all persistent data
- **Redis**: Used for queueing, caching, and pub/sub communication

> **Note**: The supervisor in coordinator mode requires the app component to be enabled. The chart includes validation to ensure this dependency is met.

The chart includes several helper templates that ensure consistent configuration across components, including:
- Database URL generation with proper parameters
- Common environment variables management
- Automatic secret generation for quickstart deployments

In a self-hosted environment, these components are arranged as follows:

```
                     ┌─────────────┐
                     │             │
                     │  Database   │
                     │ (PostgreSQL)│
                     │             │
                     └──────┬──────┘
                            │
                            ▼
┌────────────┐      ┌──────────────┐      ┌─────────────┐
│            │      │              │      │             │
│    App     │◄────►│    Worker    │◄────►│  Supervisor │
│ (Frontend) │      │ (Background) │      │(Coordinator)│
│            │      │              │      │             │
└────────────┘      └──────────────┘      └──────┬──────┘
       ▲                                         │
       │                                         ▼
       │                                  ┌─────────────┐
       └──────────────────────────────────┤    Redis    │
                                          │             │
                                          └─────────────┘
```

### Web Application (App)

The main Trigger.dev web application, which serves the UI and API endpoints. This component:

- Provides the web dashboard for managing projects and tasks
- Handles user authentication and authorization
- Serves API endpoints for the SDK to connect to
- Manages project configurations and environments
- Stores runs, logs, and metrics in the database

The app component requires a public endpoint accessible from the internet to allow SDKs to connect and register tasks.

### Worker

The Worker component processes background jobs and tasks. It:

- Handles scheduled job execution
- Processes background work for the app
- Manages webhooks and external integrations
- Executes maintenance tasks like cleanup jobs
- Communicates with the supervisor to initiate task execution

Workers can be scaled horizontally for increased throughput of background jobs.

### Supervisor

The Supervisor component acts as both a coordinator and provider:

- **Coordinator Mode**: Manages the workload API, which the run controller connects to
- **Provider Mode**: Handles dequeueing of messages and task execution
- **Kubernetes Provider**: When running in Kubernetes, it uses the Kubernetes API to create and manage task runner pods

This Helm chart is specifically designed for Kubernetes deployments, with the Supervisor configured to use the Kubernetes API for task orchestration.

#### Coordinator

The Coordinator is a specialized mode of the Supervisor that manages the workload API. It is responsible for:

- Managing job queues and task distribution
- Providing an API endpoint for run controllers to connect to
- Handling task scheduling and orchestration
- Ensuring proper execution of tasks across providers
- Tracking task status and reporting results back to the system

By default, the Supervisor runs in coordinator mode (`supervisor.mode: coordinator`). When in this mode, it uses the `coordinatorImage` settings instead of the standard `supervisorImage`.

The coordinator exposes its API on port 8020 by default, which can be customized using the `supervisor.service.port` setting.

Key configuration options for the coordinator:
- `supervisor.workloadApi.dequeueIntervalMs`: Controls how often the coordinator checks for new tasks (default: 1000ms)
- `supervisor.replicas`: Number of coordinator instances to run (for high availability, consider using 2+)
- `supervisor.service`: Service configuration for the coordinator API endpoint

For production deployments, you should consider scaling the coordinator component for high availability.

#### Kubernetes Provider

When running in Kubernetes, the Supervisor uses the Kubernetes Provider to:

- Create and manage task execution pods
- Schedule pods across the cluster
- Monitor pod execution and logs
- Collect results and return them to the coordinator
- Clean up completed task pods

The Kubernetes Provider requires appropriate RBAC permissions to create, manage, and delete pods in your cluster.

### Database Migration

When enabled, a Kubernetes Job runs before the application starts to execute database migrations. This ensures your database schema is always in sync with your application version.

The migration job can be configured with:
- Custom timeout and retry limits
- TTL for automatic cleanup
- Init containers for waiting on dependencies

## Configuration

The following table lists the configurable parameters of the Trigger.dev chart and their default values.

> **Note**: This is not a complete list of all configuration options. Please refer to the default `values.yaml` file for a complete overview of all available options.

> **Important for Production**: When deploying to production, you should consider:
> - Using secrets management for sensitive values
> - Setting appropriate resource limits and requests
> - Configuring proper SMTP settings for authentication emails
> - Using external PostgreSQL and Redis with high availability

For a minimal working configuration, you must provide:
1. Database connection details
2. Redis URL
3. Application URL settings for proper functioning

See the [Creating and Managing Values Files](#creating-and-managing-values-files) section for examples.

| Parameter                               | Description                                                                                | Default                                      |
|-----------------------------------------|--------------------------------------------------------------------------------------------|----------------------------------------------|
| `createNamespace`                       | Create a namespace for the deployment                                                      | `false`                                      |
| `namespace`                             | Namespace to create (if createNamespace is true)                                           | `"trigger-dev"`                                         |
| `quickstart.enabled`                    | Enable quickstart mode with auto-generated secrets                                          | `true`                                       |
| `image.repository`                      | Trigger.dev image repository                                                               | `ghcr.io/triggerdotdev/trigger.dev`          |
| `image.tag`                             | Trigger.dev image tag                                                                      | `3.3.18`                                      |
| `image.pullPolicy`                      | Image pull policy                                                                          | `IfNotPresent`                               |
| `image.digest`                          | Image digest for immutable deployments                                                     | `""`                                         |
| `supervisorImage.repository`            | Trigger.dev supervisor image repository (for "both" mode)                                  | `ghcr.io/triggerdotdev/supervisor`           |
| `supervisorImage.tag`                   | Trigger.dev supervisor image tag                                                           | `3.3.18`                                      |
| `supervisorImage.pullPolicy`            | Supervisor image pull policy                                                               | `IfNotPresent`                               |
| `supervisorImage.digest`                | Supervisor image digest for immutable deployments                                          | `""`                                         |
| `coordinatorImage.repository`           | Trigger.dev coordinator image repository (for "coordinator" mode)                          | `ghcr.io/triggerdotdev/coordinator`          |
| `coordinatorImage.tag`                  | Trigger.dev coordinator image tag                                                          | `3.3.18`                                     |
| `coordinatorImage.pullPolicy`           | Coordinator image pull policy                                                              | `IfNotPresent`                               |
| `coordinatorImage.digest`               | Coordinator image digest for immutable deployments                                         | `""`                                         |
| `kubernetesProviderImage.repository`    | Trigger.dev Kubernetes provider image repository (for "provider" mode)                     | `ghcr.io/triggerdotdev/provider/kubernetes`  |
| `kubernetesProviderImage.tag`           | Trigger.dev Kubernetes provider image tag                                                  | `3.3.18`                                     |
| `kubernetesProviderImage.pullPolicy`    | Kubernetes provider image pull policy                                                      | `IfNotPresent`                               |
| `kubernetesProviderImage.digest`        | Kubernetes provider image digest for immutable deployments                                 | `""`                                         |
| `app.replicas`                          | Number of app pod replicas                                                                 | `1`                                          |
| `app.env`                               | Environment variables for app pods                                                         | See values.yaml                              |
| `app.initContainers`                    | Init containers for app pods                                                               | `[]`                                         |
| `app.startupProbe`                      | Startup probe configuration for app                                                        | See values.yaml                              |
| `app.livenessProbe`                     | Liveness probe configuration for app                                                       | See values.yaml                              |
| `app.readinessProbe`                    | Readiness probe configuration for app                                                      | See values.yaml                              |
| `worker.enabled`                        | Enable worker deployment                                                                   | `true`                                       |
| `worker.replicas`                       | Number of worker pod replicas                                                              | `1`                                          |
| `worker.env`                            | Environment variables for worker pods                                                      | See values.yaml                              |
| `worker.initContainers`                 | Init containers for worker pods                                                            | `[]`                                         |
| `worker.startupProbe`                   | Startup probe configuration for worker                                                     | See values.yaml                              |
### Horizontal Pod Autoscaler

When enabled, automatically scales the application and worker pods based on resource usage metrics.

### Pod Disruption Budget

When enabled, ensures application availability during voluntary disruptions like node maintenance.

### Network Policy

When enabled, defines networking rules to control traffic to and from your Trigger.dev pods. The chart includes:
- Default rules for internal communication
- Optional allowances for external database and Redis
- Support for custom ingress and egress rules

### RBAC for Kubernetes Provider

When `rbac.create` is enabled, the chart will create the necessary Role and RoleBinding to allow the Supervisor to:
- Create and manage pods
- Access jobs
- Read ConfigMaps and Secrets
- Create and patch events
- Execute commands in pods (for debugging)

## External Services

This chart is designed to work with external services for both database and Redis:

### Neon PostgreSQL

This chart is designed to work with [Neon](https://neon.tech/) for PostgreSQL. You'll need to provide the database connection details in one of two ways:

1. Directly in the values.yaml file or using --set flags:

```yaml
database:
  externalHost: your-neon-db-host.neon.tech
  externalPort: 5432
  externalDatabase: postgres
  externalUser: postgres
  externalPassword: your-password
  sslMode: require  # Neon requires SSL
  poolMin: 0
  poolMax: 10
  connectionTimeout: 60
  statementTimeout: 30000
  idleTimeout: 10000
```

2. Using a Kubernetes secret containing the connection strings:

```bash
kubectl create secret generic trigger-db-secret \
  --from-literal=DATABASE_URL="postgres://user:password@your-neon-db-host.neon.tech:5432/postgres?sslmode=require" \
  --from-literal=DIRECT_URL="postgres://user:password@your-neon-db-host.neon.tech:5432/postgres?sslmode=require"
```

Then reference this secret in your values.yaml:

```yaml
database:
  connectionStringSecret: trigger-db-secret
```

### Upstash Redis

This chart is designed to work with [Upstash](https://upstash.com/) for Redis. You'll need to provide the Redis connection details in one of two ways:

1. Directly in the values.yaml file or using --set flags:

```yaml
redis:
  url: redis://username:password@your-upstash-redis-host:port
  tls: true
  connectTimeout: 5000
```

2. Using a Kubernetes secret containing the connection string:

```bash
kubectl create secret generic trigger-redis-secret \
  --from-literal=REDIS_URL="redis://username:password@your-upstash-redis-host:port"
```

Then reference this secret in your values.yaml:

```yaml
redis:
  secretName: trigger-redis-secret
```

## Security

The Helm chart includes security configurations that follow best practices for running applications in Kubernetes. These can be customized in your `values.yaml` file.

### Pod Security Context

The `podSecurityContext` settings apply security settings to all pods in the deployment:

```yaml
podSecurityContext:
  fsGroup: 1000
  runAsUser: 1000
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
```

### Security Context

The `securityContext` settings apply security settings to containers:

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
```

## Integrations

### External DNS

This chart can be integrated with ExternalDNS to automatically configure DNS records for your Trigger.dev deployment. To use ExternalDNS:

1. Install the ExternalDNS controller in your cluster (not part of this chart)
2. Configure your Ingress with the appropriate annotations:

```yaml
ingress:
  enabled: true
  annotations:
    external-dns.alpha.kubernetes.io/hostname: trigger.example.com
  hosts:
    - host: trigger.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Certificate Management

For TLS certificates, you can integrate with cert-manager:

1. Install cert-manager in your cluster (not part of this chart)
2. Configure your Ingress with cert-manager annotations:

```yaml
ingress:
  enabled: true
  annotations:
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

This configuration will automatically request and configure a TLS certificate for your Trigger.dev deployment.

## Production Best Practices

> **Note**: For a comprehensive guide on production deployments, please refer to the [PRODUCTION.md](./PRODUCTION.md) file included in this repository.

### Resource Management

For production deployments, we recommend configuring appropriate resource settings. See [PRODUCTION.md](./PRODUCTION.md) for detailed examples of:

- Resource requests and limits
- Priority classes
- Topology spread constraints

### High Availability

For high availability in production environments, [PRODUCTION.md](./PRODUCTION.md) provides guidance on:

- Multiple replica configurations
- Pod disruption budgets
- Anti-affinity rules

### Immutable Deployments

For improved stability and rollback capabilities in production deployments, refer to [PRODUCTION.md](./PRODUCTION.md) for:

- Using image digests instead of tags
- Secret management best practices
- Deployment strategies

## Secret Management for Production Environments

For detailed information on managing secrets in production environments, please refer to the [PRODUCTION.md](./PRODUCTION.md) file. Key topics covered include:

- Using external secret management solutions
- Implementing secret rotation
- Proper credential handling with Kubernetes secrets
- Implementation examples with various secret management tools

For telemetry settings, registry access configuration, and authentication method setup in production, also see [PRODUCTION.md](./PRODUCTION.md).

## Telemetry

By default, the Trigger.dev webapp sends telemetry data to help improve the product. You can disable telemetry by adding the following to your values.yaml:

```yaml
app:
  env:
    TRIGGER_TELEMETRY_DISABLED: "1"
```

For production-specific telemetry configurations, see [PRODUCTION.md](./PRODUCTION.md).

## Docker Registry Access

When deploying v3 projects, you'll need to configure access to a Docker registry. The Kubernetes provider needs to pull images when running tasks.

1. Create a Kubernetes secret with your registry credentials:
   ```bash
   kubectl create secret docker-registry regcred \
     --docker-server=<your-registry-server> \
     --docker-username=<your-username> \
     --docker-password=<your-password>
   ```

2. Reference this secret in your values.yaml:
   ```yaml
   imagePullSecrets:
     - name: regcred
   ```

For production-specific registry configurations, including Harbor setup, see [PRODUCTION.md](./PRODUCTION.md).

## Authentication Methods

Trigger.dev supports two authentication methods:

1. **Magic Link Email (Recommended)**: Configure basic SMTP settings in your Helm values:
   ```yaml
   app:
     env:
       SMTP_HOST: "smtp.example.com"
       SMTP_PORT: "587"
       SMTP_USER: "trigger-notifications@example.com"
       SMTP_PASSWORD: "your-smtp-password"
       SMTP_SECURE: "true"
       SMTP_FROM_ADDRESS: "no-reply@example.com"
   ```

2. **GitHub OAuth**: For GitHub authentication:
   ```yaml
   app:
     env:
       AUTH_GITHUB_CLIENT_ID: "your-github-client-id" 
       AUTH_GITHUB_CLIENT_SECRET: "your-github-client-secret"
   ```

You can restrict which email addresses can register using a regex pattern:
```yaml
app:
  env:
    WHITELISTED_EMAILS: ".*@your-company\\.com"
```

For production-specific authentication configurations with secure secret management, see [PRODUCTION.md](./PRODUCTION.md).

## Deployment Configuration

### Registry Configuration

When deploying v3 projects to your Kubernetes-hosted Trigger.dev instance, you'll need to configure registry access for both the task building and execution processes:

1. **Configure Registry in Helm Values**: Set these values when installing/upgrading your Helm chart:
   ```yaml
   app:
     env:
       # Used when CLI deploys tasks to your instance
       DEPLOY_REGISTRY_HOST: "docker.io"  # or gcr.io, ghcr.io, etc.
       DEPLOY_REGISTRY_NAMESPACE: "your-registry-namespace"
   
   # Allow Kubernetes to pull from your registry
   imagePullSecrets:
     - name: regcred  # Must be created in the same namespace
   ```

2. **Create Registry Credentials Secret**: Create a Kubernetes secret for pulling images:
   ```bash
   kubectl create secret docker-registry regcred \
     --namespace your-trigger-namespace \
     --docker-server=docker.io \
     --docker-username=your-username \
     --docker-password=your-registry-token \
     --docker-email=your-email@example.com
   ```

3. **Configure Service Account**: Ensure the service account used by pods can access your registry:
   ```yaml
   serviceAccount:
     # This is the default in the chart
     create: true
     # Add any cloud-specific annotations for registry access
     annotations:
       # Example for AWS ECR
       # eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/ecr-access-role
   ```

4. **Registry Permissions**: Ensure your registry credentials have both push and pull permissions. When deploying tasks:
   - The CLI will push images to your registry
   - The Kubernetes provider will pull these images to run tasks

For private registries in air-gapped environments, make sure your Kubernetes cluster has network access to pull from your internal registry.

### Checkpoint Support (Not Currently Supported in Kubernetes)

The Docker-based self-hosting solution includes experimental support for checkpointing long-running tasks, which allows saving the state of a running container to disk and restoring it later. This feature is useful for:

- Fan-out and fan-in patterns
- Long waits in email campaigns or workflows
- Preserving task state during maintenance

**Note**: Checkpoint support is currently only available in the Docker deployment method and is not yet supported in the Kubernetes deployment.

### Custom CLI Configuration

When using the Trigger.dev CLI with your Kubernetes-deployed instance, you'll need to:

1. **Specify Your Kubernetes Ingress URL**: Use the `--api-url` or `-a` flag when logging in
   ```bash
   # Replace with your actual ingress URL
   npx trigger.dev@latest login -a https://trigger.your-k8s-domain.com
   ```

2. **Use Custom Profiles for Different Environments**: If you maintain multiple Kubernetes clusters (dev/staging/prod)
   ```bash
   # For your staging environment
   npx trigger.dev@latest login -a https://trigger.staging.example.com --profile staging
   
   # For your production environment
   npx trigger.dev@latest login -a https://trigger.example.com --profile production
   
   # Then specify the profile when using the CLI
   npx trigger.dev@latest dev --profile staging
   ```

3. **Self-Hosted Deployment Using Your Registry**: When deploying tasks to your Helm-deployed instance, set the registry to match what you configured in your Helm values
   ```bash
   # Use the same registry host and namespace configured in your Helm values
   npx trigger.dev@latest deploy --self-hosted --push \
     --registry-host=docker.io \
     --registry-namespace=your-registry-namespace
   ```

4. **CI/CD Integration with Kubernetes**: For CI/CD pipelines deploying to your Kubernetes-hosted instance
   ```bash
   # Point at your Kubernetes ingress
   export TRIGGER_API_URL=https://trigger.your-k8s-domain.com
   export TRIGGER_ACCESS_TOKEN=your-access-token
   
   # Use the same registry configured in your Helm values
   npx trigger.dev@latest deploy --self-hosted --push \
     --registry-host=$(REGISTRY_HOST) \
     --registry-namespace=$(REGISTRY_NAMESPACE)
   ```

5. **Version Pinning (Optional)**: For CI/CD with pinned versions
   ```bash
   # Use the same version as your deployed Helm chart
   npx trigger.dev@$(TRIGGER_VERSION) deploy --self-hosted --push
   ```
   
   Note: This is only relevant for task deployment, not for deploying the Trigger.dev platform itself, which is handled by Helm.

### Large Payloads

For handling large payloads in tasks, you may need to configure:

```yaml
app:
  env:
    # Increase maximum payload size (default 5MB)
    MAX_PAYLOAD_SIZE_MB: "20"
```

This is particularly useful for tasks that process large files or data sets.

## Self-Hosting Considerations

### System Requirements

Based on the Trigger.dev self-hosting documentation, here are the minimum system requirements for a Kubernetes installation:

- **CPU**: 4 vCPU cores (minimum)
- **Memory**: 8GB RAM (minimum)
- **Storage**: Depends on your workload, but plan for at least 20GB to start
- **Kubernetes Version**: 1.19+ (as specified in prerequisites)

For production deployments, you should scale these resources based on your workload:

| Component   | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-------------|-------------|----------------|-----------|--------------|
| App         | 200m        | 512Mi          | -         | 1Gi          |
| Worker      | 300m        | 512Mi          | -         | 1.5Gi        |
| Supervisor  | 200m        | 512Mi          | -         | 1Gi          |
| Task Pods   | Varies      | Varies         | Varies    | Varies       |

These resource settings follow the Kubernetes best practice of:
- Setting CPU **requests** to guarantee minimum resources for each component
- Omitting CPU **limits** to allow for better resource utilization and bursting during peak loads
- Setting memory **requests** to guarantee minimum allocations
- Setting moderate memory **limits** to prevent out-of-memory crashes while allowing flexibility

This approach:
- Guarantees minimum resources for stable operation (700m CPU, 1.5Gi memory total)
- Allows components to utilize available cluster capacity during peak loads
- Prevents any single component from consuming all available memory
- Provides better overall resource utilization in production environments

For more constrained environments or specific workload patterns, you can adjust these values in your `values.yaml` file.

#### Architecture Compatibility

As noted in the Trigger.dev self-hosting documentation, there are some architecture compatibility considerations:

- **ARM Support Limitations**: The v3 worker components currently have limited ARM architecture support
- **Affected Environments**: ARM-based Kubernetes clusters (like those running on Apple Silicon or AWS Graviton)
- **Workaround**: For ARM-based environments, consider using x86_64 emulation or running on x86_64 nodes

This is an important consideration when deploying on certain cloud providers that offer ARM-based instances or for local development clusters on Apple Silicon Macs.

### Additional Environment Variables

Several important environment variables control Trigger.dev platform behavior:

```yaml
app:
  env:
    # Required for properly configuring external access
    TRIGGER_PROTOCOL: "https"  # http or https
    TRIGGER_DOMAIN: "your-trigger-instance.example.com"
    
    # Platform coordination (advanced settings)
    PROVIDER_SECRET: "generate-a-32-character-hex-secret"  # For provider authentication
    COORDINATOR_SECRET: "generate-a-32-character-hex-secret"  # For coordinator authentication
    
    # For email based auth
    MAGIC_LINK_SECRET: "generate-a-16-character-hex-secret" 
    SESSION_SECRET: "generate-a-16-character-hex-secret"
    ENCRYPTION_KEY: "generate-a-16-character-hex-secret"
    
    # For disabling checkpoint simulation (if checkpoint support is implemented)
    FORCE_CHECKPOINT_SIMULATION: "0"  # Set to 0 to disable simulation
    
    # For real-time API features
    REALTIME_WEBSOCKET_ENABLED: "true"
```

When using quickstart mode (`quickstart.enabled: true`), these secrets are automatically generated for you. For production deployments, you should provide your own secrets through your preferred secret management solution.

### Security Caveats

The following security considerations are important when self-hosting Trigger.dev:

1. **Task Resource Limits**: The Kubernetes provider doesn't currently enforce resource limits for tasks automatically. To mitigate this:
   - Configure resource quotas on your namespace
   - Set default resource limits in your Kubernetes configuration
   - Always test your tasks with resource constraints before deploying to production

2. **Network Security**: Task pods run with host networking by default. Consider:
   - Using network policies to restrict pod communication
   - Implementing service meshes for additional security
   - Restricting egress traffic from your Kubernetes cluster

3. **Worker Access**: The worker components need access to Kubernetes APIs. Use RBAC with least privilege:
   - The chart includes required permissions in the `rbac.rules` section
   - Consider further restricting these permissions for production environments
   - Use a dedicated service account with minimal permissions

4. **Authentication Security**: If using GitHub OAuth authentication:
   - Be aware that it doesn't support email restrictions
   - This could allow unauthorized access to your self-hosted instance
   - Use the magic link email authentication method with `WHITELISTED_EMAILS` for better access control

### Scaling Considerations

For larger installations or high availability:

1. **Multiple Worker Nodes**: Increase `worker.replicas` to handle more background jobs
2. **Supervisor High Availability**: Set `supervisor.replicas` to 2+ for coordinator redundancy
3. **Database Scaling**: Ensure your external PostgreSQL database can handle the load
4. **Redis Scaling**: Configure your external Redis instance for appropriate throughput

Self-hosted Trigger.dev deployments currently don't support scaling worker components across multiple machines in the same way as Docker-based deployments, but you can achieve horizontal scaling by increasing the replica count in the Helm chart.

## Docker vs. Kubernetes Deployment

The Trigger.dev documentation primarily covers Docker-based self-hosting, but this Helm chart provides a Kubernetes-native deployment. Here's how they compare:

| Feature | Docker Deployment | Kubernetes Deployment |
|---------|------------------|----------------------|
| Installation Complexity | Lower - simple docker-compose setup | Higher - requires Kubernetes knowledge |
| Scaling | Limited to single machine or manual clustering | Native horizontal scaling with replicas |
| High Availability | Limited without additional configuration | Built-in with proper configuration |
| Infrastructure Requirements | Can run on a single server | Requires a Kubernetes cluster |
| Resource Isolation | Container-level isolation | Pod-level isolation with namespace controls |
| Checkpoint Support | Experimental support available | Not currently supported |
| Deployment Model | Manual container management | Declarative with Helm |
| Resource Efficiency | May be better for small deployments | More efficient for larger deployments |
| Monitoring & Logging | Requires additional setup | Can integrate with Kubernetes monitoring |
| Update Process | Manual update of containers | Rolling updates with Helm |

When choosing between Docker and Kubernetes deployments, consider:

1. **Existing Infrastructure**: If you're already running Kubernetes, this Helm chart provides better integration
2. **Scale Requirements**: For larger deployments, Kubernetes offers better scaling capabilities
3. **Operational Knowledge**: Kubernetes requires more specialized knowledge to operate
4. **Feature Needs**: If you need checkpoint support, Docker deployment may be preferred
5. **High Availability**: Kubernetes makes it easier to achieve HA configurations

For most enterprise deployments, the Kubernetes approach provided by this Helm chart offers better scalability, reliability, and integration with existing infrastructure.

## Troubleshooting

### Diagnosing Issues

If you encounter problems with your Trigger.dev deployment, here are some debugging steps:

1. **Pod Startup Issues**: Check if all pods are running and their logs:
   ```bash
   # Check pod status
   kubectl get pods -n your-namespace -l app.kubernetes.io/instance=trigger-dev
   
   # Check app logs
   kubectl logs -l app.kubernetes.io/component=app -n your-namespace
   
   # Check worker logs
   kubectl logs -l app.kubernetes.io/component=worker -n your-namespace
   
   # Check supervisor logs for errors
   kubectl logs -l app.kubernetes.io/component=supervisor -n your-namespace
   
   # Check RBAC permissions
   kubectl auth can-i create pods --as=system:serviceaccount:your-namespace:trigger-dev
   
   # Verify registry access by running a test job
   kubectl create job test-pull --image=<your-registry>/<repository>/<image>:<tag> -n your-namespace
   ```

2. **Task Access Issues**: If tasks can't access required resources:
   ```bash
   # Check network policies
   kubectl get networkpolicies -n your-namespace
   
   # Check if pods have correct service account
   kubectl get pods -o jsonpath='{.items[*].spec.serviceAccountName}' -n your-namespace
   
   # Verify DNS resolution
   kubectl run -it --rm --restart=Never dns-test --image=busybox:1.28 -- nslookup trigger-dev-app.your-namespace
   ```

3. **Task Log Access**: To view logs from task execution pods:
   ```bash
   # Find task runner pods
   kubectl get pods -l trigger.dev/task-runner=true -n your-namespace
   
   # Stream logs from a specific task
   kubectl logs -f <task-pod-name> -n your-namespace
   ```

4. **Database Connection Issues**:
   ```bash
   # Check if migration job completed successfully
   kubectl logs job/trigger-dev-migrations -n your-namespace
   
   # Test database connectivity from inside the cluster
   kubectl run -it --rm --restart=Never db-test --image=postgres:14-alpine -- psql "postgresql://username:password@your-db-host:5432/database"
   ```

### Helm Chart Configuration Debugging

If you suspect configuration issues:

```bash
# Dump all applied values (with defaults)
helm get values trigger-dev -a -n your-namespace > applied-values.yaml

# Compare your values with applied values
diff your-values.yaml applied-values.yaml

# Check all rendered templates
helm get manifest trigger-dev -n your-namespace > applied-manifest.yaml

# Check chart version and status
helm list -n your-namespace
```

### Common Issues & FAQs

#### "I can't connect to the database"

- Verify your database credentials and connection string
- Check if your firewall allows connections from your Kubernetes cluster
- Ensure SSL settings match your database requirements:
  ```yaml
  database:
    sslMode: require  # Try changing to "prefer" or other modes if needed
  ```
- For Neon databases, make sure you're using the correct connection string format and SSL mode

#### "Pods are failing to start"

- Check the pod logs: `kubectl logs -l app.kubernetes.io/name=trigger-dev -n your-namespace`
- Ensure you've set all the required environment variables
- Verify your Kubernetes cluster has enough resources
- Check for image pull errors: `kubectl describe pod <pod-name> -n your-namespace`
- Verify your persistent volume claims if using persistent storage: `kubectl get pvc -n your-namespace`

#### "How do I set up email authentication?"

Configure SMTP settings in your values file:
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

#### "Tasks are not executing"

- Check supervisor logs: `kubectl logs -l app.kubernetes.io/component=supervisor -n your-namespace`
- Verify registry access is properly configured
- Ensure RBAC permissions are set correctly
- Check network connectivity between pods
- Verify the task code is correctly defined and registered

#### "I'm getting errors with the CLI and my self-hosted instance"

- Ensure your CLI version is compatible with your self-hosted instance
- Verify the URL configuration is correct: `npx trigger.dev@latest login -a https://your-trigger-domain.com`
- Check that your API key has the necessary permissions
- Confirm that your network allows connections to your self-hosted instance

For additional assistance, join the dedicated [self-hosting channel](https://trigger.dev/discord) on Discord or create an issue in the [GitHub repository](https://github.com/hongkongkiwi/helm-trigger-dev/issues).

## Conclusion and Next Steps

After successfully deploying Trigger.dev using this Helm chart, here are some recommended next steps:

1. **Set up your first project**
   - Create an account in the dashboard
   - Create a new project and obtain your API key
   - Install the Trigger.dev SDK in your application
   - Create your first task or job

2. **Customize your deployment**
   - Configure authentication providers
   - Set up email notifications
   - Add custom environment variables
   - Scale components based on your workload

3. **Monitor your deployment**
   - Set up logging with a solution like Datadog, Grafana, or the ELK stack
   - Configure alerts for critical components
   - Regularly check the Trigger.dev dashboard for job statuses

4. **Keep up to date**
   - Join the [Trigger.dev Discord](https://trigger.dev/discord) for community support
   - Follow the [Trigger.dev GitHub repository](https://github.com/triggerdotdev/trigger.dev) for updates
   - Check regularly for new chart versions that contain bug fixes and features

For more detailed information about using Trigger.dev, refer to the [official documentation](https://trigger.dev/docs/documentation/introduction).