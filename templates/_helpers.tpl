{{/*
Validate required values
*/}}
{{- define "trigger-dev.validateValues" -}}
{{/* Database validation */}}
{{- if and (not .Values.quickstart.enabled) (not .Values.database.connectionStringSecret) (eq .Values.database.externalHost "your-neon-db-host.neon.tech") -}}
{{- fail "Please provide a valid database host or connection string secret" -}}
{{- end -}}

{{/* Redis validation */}}
{{- if and (not .Values.quickstart.enabled) (not .Values.redis.secretName) (eq .Values.redis.url "redis://username:password@host:port") -}}
{{- fail "Please provide a valid Redis URL or connection string secret" -}}
{{- end -}}

{{/* Supervisor mode validation */}}
{{- if and .Values.supervisor.enabled (not (has .Values.supervisor.mode (list "coordinator" "provider" "both"))) -}}
{{- fail "supervisor.mode must be one of: coordinator, provider, both" -}}
{{- end -}}

{{/* Dependency validation */}}
{{- if and .Values.supervisor.enabled (or (eq .Values.supervisor.mode "coordinator") (eq .Values.supervisor.mode "both")) (not .Values.app.enabled) -}}
{{- fail "app must be enabled when supervisor is in coordinator or both mode" -}}
{{- end -}}

{{/* Worker validation */}}
{{- if and (not .Values.worker.enabled) (not .Values.app.enabled) -}}
{{- fail "At least one of app or worker must be enabled" -}}
{{- end -}}

{{/* Resource requests validation */}}
{{- if and .Values.app.enabled (not .Values.resources.app) -}}
{{- fail "resources.app is required when app is enabled" -}}
{{- end -}}
{{- if and .Values.worker.enabled (not .Values.resources.worker) -}}
{{- fail "resources.worker is required when worker is enabled" -}}
{{- end -}}
{{- if and .Values.supervisor.enabled (not .Values.resources.supervisor) -}}
{{- fail "resources.supervisor is required when supervisor is enabled" -}}
{{- end -}}

{{/* Image validation */}}
{{- if and (not .Values.image.digest) (eq .Values.image.tag "") -}}
{{- fail "Either image.tag or image.digest must be specified" -}}
{{- end -}}

{{/* Production mode validations */}}
{{- if not .Values.quickstart.enabled -}}
  {{/* TLS validation for production */}}
  {{- if and .Values.ingress.enabled (not .Values.ingress.tls) -}}
    {{- fail "TLS must be configured for production ingress" -}}
  {{- end -}}

  {{/* Security context validation */}}
  {{- if not .Values.podSecurityContext.runAsNonRoot -}}
    {{- fail "podSecurityContext.runAsNonRoot should be enabled in production" -}}
  {{- end -}}

  {{/* Resource limits validation */}}
  {{- if not (and .Values.resources.app.limits .Values.resources.worker.limits .Values.resources.supervisor.limits) -}}
    {{- fail "Resource limits should be set for all components in production" -}}
  {{- end -}}

  {{/* High availability validation */}}
  {{- if eq (int .Values.app.replicas) 1 -}}
    {{- fail "Multiple replicas recommended for production deployments" -}}
  {{- end -}}
{{- end -}}

{{/* Network policy validation */}}
{{- if and (not .Values.quickstart.enabled) (not .Values.networkPolicy.enabled) -}}
{{- fail "Network policies should be enabled in production" -}}
{{- end -}}

{{/* Database SSL mode validation */}}
{{- if and (not .Values.quickstart.enabled) (eq .Values.database.sslMode "disable") -}}
{{- fail "SSL should be enabled for database connections in production" -}}
{{- end -}}

{{/* Redis TLS validation */}}
{{- if and (not .Values.quickstart.enabled) (not .Values.redis.tls) -}}
{{- fail "TLS should be enabled for Redis connections in production" -}}
{{- end -}}

{{/* Pod disruption budget validation */}}
{{- if and (not .Values.quickstart.enabled) (not .Values.podDisruptionBudget.enabled) -}}
{{- fail "Pod disruption budget should be enabled in production" -}}
{{- end -}}

{{/* Probe validation */}}
{{- if or (not .Values.app.livenessProbe) (not .Values.app.readinessProbe) -}}
{{- fail "Both liveness and readiness probes should be configured" -}}
{{- end -}}

{{/* Service account validation */}}
{{- if and .Values.rbac.create (not .Values.serviceAccount.create) -}}
{{- fail "Service account must be created when RBAC is enabled" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "trigger-dev.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "trigger-dev.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trigger-dev.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "trigger-dev.labels" -}}
helm.sh/chart: {{ include "trigger-dev.chart" . }}
{{ include "trigger-dev.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "trigger-dev.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trigger-dev.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "trigger-dev.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "trigger-dev.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define app name
*/}}
{{- define "trigger-dev.app.name" -}}
{{- printf "%s-app" (include "trigger-dev.fullname" .) }}
{{- end }}

{{/*
Define worker name
*/}}
{{- define "trigger-dev.worker.name" -}}
{{- printf "%s-worker" (include "trigger-dev.fullname" .) }}
{{- end }}

{{/*
Define supervisor name
*/}}
{{- define "trigger-dev.supervisor.name" -}}
{{- printf "%s-supervisor" (include "trigger-dev.fullname" .) }}
{{- end }}

{{/*
Define db migration job name
*/}}
{{- define "trigger-dev.db-migrate.name" -}}
{{- printf "%s-migrations" (include "trigger-dev.fullname" .) }}
{{- end }}

{{/*
Generate database url
*/}}
{{- define "trigger-dev.databaseUrl" -}}
{{- $dbUrl := printf "postgres://%s:%s@%s:%s/%s" .Values.database.externalUser .Values.database.externalPassword .Values.database.externalHost (toString .Values.database.externalPort) .Values.database.externalDatabase -}}
{{- $params := dict -}}

{{/* Add SSL Mode */}}
{{- if .Values.database.sslMode -}}
  {{- $_ := set $params "sslmode" .Values.database.sslMode -}}
{{- end -}}

{{/* Add pgbouncer and pool settings if enabled */}}
{{- if .Values.database.usePgBouncer -}}
  {{- $_ := set $params "pgbouncer" "true" -}}
  {{- $_ := set $params "pool_timeout" "15" -}}
{{- end -}}

{{/* Set connection timeout */}}
{{- if .Values.database.connectionTimeout -}}
  {{- $_ := set $params "connect_timeout" (toString .Values.database.connectionTimeout) -}}
{{- end -}}

{{/* Set statement timeout */}}
{{- if .Values.database.statementTimeout -}}
  {{- $_ := set $params "statement_timeout" (toString .Values.database.statementTimeout) -}}
{{- end -}}

{{/* Set idle timeout */}}
{{- if .Values.database.idleTimeout -}}
  {{- $_ := set $params "idle_timeout" (toString .Values.database.idleTimeout) -}}
{{- end -}}

{{/* Add any additional params */}}
{{- range $key, $value := .Values.database.additionalParams -}}
  {{- $_ := set $params $key $value -}}
{{- end -}}

{{/* Build the query string */}}
{{- $queryParams := list -}}
{{- range $key, $value := $params -}}
  {{- $queryParams = append $queryParams (printf "%s=%s" $key $value) -}}
{{- end -}}
{{- $queryString := join "&" $queryParams -}}

{{- if $queryParams -}}
{{- printf "%s?%s" $dbUrl $queryString -}}
{{- else -}}
{{- printf "%s" $dbUrl -}}
{{- end -}}
{{- end -}}

{{/*
Generate database direct url (no connection pooling)
*/}}
{{- define "trigger-dev.databaseDirectUrl" -}}
{{- $dbUrl := printf "postgres://%s:%s@%s:%s/%s" .Values.database.externalUser .Values.database.externalPassword .Values.database.externalHost (toString .Values.database.externalPort) .Values.database.externalDatabase -}}
{{- $params := dict -}}

{{/* Add SSL Mode */}}
{{- if .Values.database.sslMode -}}
  {{- $_ := set $params "sslmode" .Values.database.sslMode -}}
{{- end -}}

{{/* Set connection timeout */}}
{{- if .Values.database.connectionTimeout -}}
  {{- $_ := set $params "connect_timeout" (toString .Values.database.connectionTimeout) -}}
{{- end -}}

{{/* Add any additional params except pgbouncer-related ones */}}
{{- range $key, $value := .Values.database.additionalParams -}}
  {{- if and (ne $key "pgbouncer") (ne $key "pool_timeout") -}}
    {{- $_ := set $params $key $value -}}
  {{- end -}}
{{- end -}}

{{/* Build the query string if there are any params */}}
{{- if gt (len $params) 0 -}}
  {{- $queryParams := list -}}
  {{- range $key, $value := $params -}}
    {{- $queryParams = append $queryParams (printf "%s=%s" $key $value) -}}
  {{- end -}}
  {{- $queryString := join "&" $queryParams -}}
  {{- printf "%s?%s" $dbUrl $queryString -}}
{{- else -}}
  {{- printf "%s" $dbUrl -}}
{{- end -}}
{{- end -}}

{{/* Note: The generateSecrets template is now maintained in _quickstart.tpl */}}

{{/*
Generate Redis URL with appropriate TLS configuration
*/}}
{{- define "trigger-dev.redisUrl" -}}
{{- if and .Values.redis.url .Values.redis.tls -}}
  {{- if hasPrefix "redis://" .Values.redis.url -}}
    {{- printf "%s" (replace "redis://" "rediss://" .Values.redis.url) -}}
  {{- else -}}
    {{- printf "%s" .Values.redis.url -}}
  {{- end -}}
{{- else -}}
  {{- printf "%s" .Values.redis.url -}}
{{- end -}}
{{- end -}}

{{/*
Common environment variables used across deployments
*/}}
{{- define "trigger-dev.commonEnv" -}}
{{- if .Values.quickstart.enabled }}
- name: SESSION_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-secrets" (include "trigger-dev.fullname" .) }}
      key: SESSION_SECRET
- name: MAGIC_LINK_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-secrets" (include "trigger-dev.fullname" .) }}
      key: MAGIC_LINK_SECRET
- name: ENCRYPTION_KEY
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-secrets" (include "trigger-dev.fullname" .) }}
      key: ENCRYPTION_KEY
- name: TRIGGER_WORKER_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-secrets" (include "trigger-dev.fullname" .) }}
      key: TRIGGER_WORKER_TOKEN
- name: MANAGED_WORKER_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ printf "%s-secrets" (include "trigger-dev.fullname" .) }}
      key: MANAGED_WORKER_SECRET
{{- end }}
{{- if .Values.database.connectionStringSecret }}
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.database.connectionStringSecret }}
      key: DATABASE_URL
- name: DIRECT_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.database.connectionStringSecret }}
      key: DIRECT_URL
{{- else }}
- name: DATABASE_URL
  value: {{ include "trigger-dev.databaseUrl" . | quote }}
- name: DIRECT_URL
  value: {{ include "trigger-dev.databaseDirectUrl" . | quote }}
{{- end }}
{{- if .Values.redis.secretName }}
- name: REDIS_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.secretName }}
      key: REDIS_URL
{{- else }}
- name: REDIS_URL
  value: {{ include "trigger-dev.redisUrl" . | quote }}
{{- end }}
{{- with .Values.env }}
{{- toYaml . }}
{{- end }}
{{- end -}}

{{/*
Get app image configuration
*/}}
{{- define "trigger-dev.app.image" -}}
{{- if .Values.image.digest }}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
{{- end }}

{{/*
Get worker image configuration
*/}}
{{- define "trigger-dev.worker.image" -}}
{{- if .Values.worker.image.digest }}
{{- printf "%s@%s" .Values.worker.image.repository .Values.worker.image.digest }}
{{- else }}
{{- printf "%s:%s" .Values.worker.image.repository (.Values.worker.image.tag | default .Chart.AppVersion) }}
{{- end }}
{{- end }}

{{/*
Get supervisor image configuration based on mode
*/}}
{{- define "trigger-dev.supervisor.image" -}}
{{- if eq .Values.supervisor.mode "coordinator" }}
  {{- if .Values.coordinatorImage.digest }}
  {{- printf "%s@%s" .Values.coordinatorImage.repository .Values.coordinatorImage.digest }}
  {{- else }}
  {{- printf "%s:%s" .Values.coordinatorImage.repository (.Values.coordinatorImage.tag | default .Chart.AppVersion) }}
  {{- end }}
{{- else if eq .Values.supervisor.mode "provider" }}
  {{- if .Values.kubernetesProviderImage.digest }}
  {{- printf "%s@%s" .Values.kubernetesProviderImage.repository .Values.kubernetesProviderImage.digest }}
  {{- else }}
  {{- printf "%s:%s" .Values.kubernetesProviderImage.repository (.Values.kubernetesProviderImage.tag | default .Chart.AppVersion) }}
  {{- end }}
{{- else }}
  {{- if .Values.supervisorImage.digest }}
  {{- printf "%s@%s" .Values.supervisorImage.repository .Values.supervisorImage.digest }}
  {{- else }}
  {{- printf "%s:%s" .Values.supervisorImage.repository (.Values.supervisorImage.tag | default .Chart.AppVersion) }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Validate image configuration
*/}}
{{- define "trigger-dev.validateImage" -}}
{{- $imageConfig := . -}}
{{- if and (not $imageConfig.digest) (eq $imageConfig.tag "") -}}
{{- fail "Either tag or digest must be specified for image" -}}
{{- end -}}
{{- end -}}

{{/*
Validate resource configuration
*/}}
{{- define "trigger-dev.validateResources" -}}
{{- $resourceConfig := . -}}
{{- if not (and $resourceConfig.requests $resourceConfig.requests.cpu $resourceConfig.requests.memory) -}}
{{- fail "Resource requests must specify both CPU and memory" -}}
{{- end -}}
{{- end -}}

{{/*
Validate probe configuration
*/}}
{{- define "trigger-dev.validateProbe" -}}
{{- $probe := . -}}
{{- if not (and $probe.periodSeconds $probe.timeoutSeconds $probe.successThreshold $probe.failureThreshold) -}}
{{- fail "Probe must specify all timing parameters" -}}
{{- end -}}
{{- end -}} 