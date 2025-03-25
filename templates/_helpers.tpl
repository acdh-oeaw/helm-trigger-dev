{{/*
Default values for worker and service configuration
*/}}
{{- define "trigger-dev.defaultValues" -}}
{{/* Name defaults */}}
{{- if not .Values.nameOverride -}}
{{- $_ := set .Values "nameOverride" "trigger-dev" -}}
{{- end -}}
{{- if not .Values.fullnameOverride -}}
{{- $_ := set .Values "fullnameOverride" "trigger-dev" -}}
{{- end -}}

{{/* Ingress defaults */}}
{{- if not .Values.ingress -}}
{{- $_ := set .Values "ingress" dict -}}
{{- end -}}
{{- if not (hasKey .Values.ingress "enabled") -}}
{{- $_ := set .Values.ingress "enabled" false -}}
{{- end -}}
{{- if not .Values.ingress.className -}}
{{- $_ := set .Values.ingress "className" "" -}}
{{- end -}}
{{- if not .Values.ingress.annotations -}}
{{- $_ := set .Values.ingress "annotations" dict -}}
{{- end -}}
{{- if not .Values.ingress.hosts -}}
{{- $_ := set .Values.ingress "hosts" list -}}
{{- end -}}
{{- if not .Values.ingress.tls -}}
{{- $_ := set .Values.ingress "tls" list -}}
{{- end -}}

{{/* Network policy defaults */}}
{{- if not .Values.networkPolicy -}}
{{- $_ := set .Values "networkPolicy" dict -}}
{{- end -}}
{{- if not (hasKey .Values.networkPolicy "enabled") -}}
{{- $_ := set .Values.networkPolicy "enabled" true -}}
{{- end -}}

{{/* Security context defaults */}}
{{- if not .Values.securityContext -}}
{{- $_ := set .Values "securityContext" dict -}}
{{- end -}}
{{- if not (hasKey .Values.securityContext "capabilities") -}}
{{- $_ := set .Values.securityContext "capabilities" dict -}}
{{- end -}}
{{- if not (hasKey .Values.securityContext.capabilities "drop") -}}
{{- $_ := set .Values.securityContext.capabilities "drop" (list "ALL") -}}
{{- end -}}
{{- if not (hasKey .Values.securityContext "readOnlyRootFilesystem") -}}
{{- $_ := set .Values.securityContext "readOnlyRootFilesystem" true -}}
{{- end -}}
{{- if not (hasKey .Values.securityContext "runAsNonRoot") -}}
{{- $_ := set .Values.securityContext "runAsNonRoot" true -}}
{{- end -}}
{{- if not (hasKey .Values.securityContext "runAsUser") -}}
{{- $_ := set .Values.securityContext "runAsUser" 1000 -}}
{{- end -}}

{{/* Pod security context defaults */}}
{{- if not .Values.podSecurityContext -}}
{{- $_ := set .Values "podSecurityContext" dict -}}
{{- end -}}
{{- if not (hasKey .Values.podSecurityContext "runAsNonRoot") -}}
{{- $_ := set .Values.podSecurityContext "runAsNonRoot" true -}}
{{- end -}}

{{/* Pod disruption budget defaults */}}
{{- if not .Values.podDisruptionBudget -}}
{{- $_ := set .Values "podDisruptionBudget" dict -}}
{{- end -}}
{{- if not (hasKey .Values.podDisruptionBudget "enabled") -}}
{{- $_ := set .Values.podDisruptionBudget "enabled" true -}}
{{- end -}}

{{/* App probe defaults */}}
{{- if not .Values.app -}}
{{- $_ := set .Values "app" dict -}}
{{- end -}}
{{- if not .Values.app.livenessProbe -}}
{{- $_ := set .Values.app "livenessProbe" dict -}}
{{- end -}}
{{- if not .Values.app.livenessProbe.periodSeconds -}}
{{- $_ := set .Values.app.livenessProbe "periodSeconds" 30 -}}
{{- end -}}
{{- if not .Values.app.livenessProbe.timeoutSeconds -}}
{{- $_ := set .Values.app.livenessProbe "timeoutSeconds" 5 -}}
{{- end -}}
{{- if not .Values.app.livenessProbe.successThreshold -}}
{{- $_ := set .Values.app.livenessProbe "successThreshold" 1 -}}
{{- end -}}
{{- if not .Values.app.livenessProbe.failureThreshold -}}
{{- $_ := set .Values.app.livenessProbe "failureThreshold" 3 -}}
{{- end -}}
{{- if not .Values.app.readinessProbe -}}
{{- $_ := set .Values.app "readinessProbe" dict -}}
{{- end -}}
{{- if not .Values.app.readinessProbe.periodSeconds -}}
{{- $_ := set .Values.app.readinessProbe "periodSeconds" 10 -}}
{{- end -}}
{{- if not .Values.app.readinessProbe.timeoutSeconds -}}
{{- $_ := set .Values.app.readinessProbe "timeoutSeconds" 5 -}}
{{- end -}}
{{- if not .Values.app.readinessProbe.successThreshold -}}
{{- $_ := set .Values.app.readinessProbe "successThreshold" 1 -}}
{{- end -}}
{{- if not .Values.app.readinessProbe.failureThreshold -}}
{{- $_ := set .Values.app.readinessProbe "failureThreshold" 3 -}}
{{- end -}}

{{/* Worker probe defaults */}}
{{- if not .Values.worker -}}
{{- $_ := set .Values "worker" dict -}}
{{- end -}}
{{- if not .Values.worker.livenessProbe -}}
{{- $_ := set .Values.worker "livenessProbe" dict -}}
{{- end -}}
{{- if not .Values.worker.livenessProbe.periodSeconds -}}
{{- $_ := set .Values.worker.livenessProbe "periodSeconds" 30 -}}
{{- end -}}
{{- if not .Values.worker.livenessProbe.timeoutSeconds -}}
{{- $_ := set .Values.worker.livenessProbe "timeoutSeconds" 5 -}}
{{- end -}}
{{- if not .Values.worker.livenessProbe.successThreshold -}}
{{- $_ := set .Values.worker.livenessProbe "successThreshold" 1 -}}
{{- end -}}
{{- if not .Values.worker.livenessProbe.failureThreshold -}}
{{- $_ := set .Values.worker.livenessProbe "failureThreshold" 3 -}}
{{- end -}}
{{- if not .Values.worker.readinessProbe -}}
{{- $_ := set .Values.worker "readinessProbe" dict -}}
{{- end -}}
{{- if not .Values.worker.readinessProbe.periodSeconds -}}
{{- $_ := set .Values.worker.readinessProbe "periodSeconds" 10 -}}
{{- end -}}
{{- if not .Values.worker.readinessProbe.timeoutSeconds -}}
{{- $_ := set .Values.worker.readinessProbe "timeoutSeconds" 5 -}}
{{- end -}}
{{- if not .Values.worker.readinessProbe.successThreshold -}}
{{- $_ := set .Values.worker.readinessProbe "successThreshold" 1 -}}
{{- end -}}
{{- if not .Values.worker.readinessProbe.failureThreshold -}}
{{- $_ := set .Values.worker.readinessProbe "failureThreshold" 3 -}}
{{- end -}}

{{/* RBAC defaults */}}
{{- if not .Values.rbac -}}
{{- $_ := set .Values "rbac" dict -}}
{{- end -}}
{{- if not (hasKey .Values.rbac "create") -}}
{{- $_ := set .Values.rbac "create" true -}}
{{- end -}}

{{/* Service account defaults */}}
{{- if not .Values.serviceAccount -}}
{{- $_ := set .Values "serviceAccount" dict -}}
{{- end -}}
{{- if not (hasKey .Values.serviceAccount "create") -}}
{{- $_ := set .Values.serviceAccount "create" true -}}
{{- end -}}
{{- if not .Values.serviceAccount.name -}}
{{- $_ := set .Values.serviceAccount "name" "" -}}
{{- end -}}

{{/* Image defaults */}}
{{- if not .Values.image -}}
{{- $_ := set .Values "image" dict -}}
{{- end -}}
{{- if not .Values.image.repository -}}
{{- $_ := set .Values.image "repository" "ghcr.io/triggerdotdev/trigger.dev" -}}
{{- end -}}
{{- if not .Values.image.tag -}}
{{- $_ := set .Values.image "tag" "latest" -}}
{{- end -}}
{{- if not .Values.image.pullPolicy -}}
{{- $_ := set .Values.image "pullPolicy" "IfNotPresent" -}}
{{- end -}}
{{- if not .Values.image.digest -}}
{{- $_ := set .Values.image "digest" "" -}}
{{- end -}}

{{/* Worker defaults */}}
{{- if not .Values.worker -}}
{{- $_ := set .Values "worker" dict -}}
{{- end -}}
{{- if not .Values.worker.enabled -}}
{{- $_ := set .Values.worker "enabled" true -}}
{{- end -}}
{{- if not .Values.worker.service -}}
{{- $_ := set .Values.worker "service" dict -}}
{{- end -}}
{{- if not .Values.worker.service.port -}}
{{- $_ := set .Values.worker.service "port" 3000 -}}
{{- end -}}
{{- if not .Values.worker.service.type -}}
{{- $_ := set .Values.worker.service "type" "ClusterIP" -}}
{{- end -}}

{{/* Worker image defaults */}}
{{- if not .Values.worker.image -}}
{{- $_ := set .Values.worker "image" dict -}}
{{- end -}}
{{- if not .Values.worker.image.repository -}}
{{- $_ := set .Values.worker.image "repository" "ghcr.io/triggerdotdev/trigger.dev" -}}
{{- end -}}
{{- if not .Values.worker.image.tag -}}
{{- $_ := set .Values.worker.image "tag" "latest" -}}
{{- end -}}
{{- if not .Values.worker.image.pullPolicy -}}
{{- $_ := set .Values.worker.image "pullPolicy" "IfNotPresent" -}}
{{- end -}}
{{- if not .Values.worker.image.digest -}}
{{- $_ := set .Values.worker.image "digest" "" -}}
{{- end -}}

{{/* App defaults */}}
{{- if not .Values.app -}}
{{- $_ := set .Values "app" dict -}}
{{- end -}}
{{- if not .Values.app.enabled -}}
{{- $_ := set .Values.app "enabled" true -}}
{{- end -}}
{{- if not .Values.app.service -}}
{{- $_ := set .Values.app "service" dict -}}
{{- end -}}
{{- if not .Values.app.service.port -}}
{{- $_ := set .Values.app.service "port" 3000 -}}
{{- end -}}
{{- if not .Values.app.service.type -}}
{{- $_ := set .Values.app.service "type" "ClusterIP" -}}
{{- end -}}
{{- if not .Values.app.replicas -}}
{{- $_ := set .Values.app "replicas" 1 -}}
{{- end -}}

{{/* Supervisor defaults */}}
{{- if not .Values.supervisor -}}
{{- $_ := set .Values "supervisor" dict -}}
{{- end -}}
{{- if not .Values.supervisor.enabled -}}
{{- $_ := set .Values.supervisor "enabled" false -}}
{{- end -}}
{{- if not .Values.supervisor.replicas -}}
{{- $_ := set .Values.supervisor "replicas" 1 -}}
{{- end -}}
{{- if not .Values.supervisor.mode -}}
{{- $_ := set .Values.supervisor "mode" "both" -}}
{{- end -}}
{{- if not .Values.supervisor.nodeEnv -}}
{{- $_ := set .Values.supervisor "nodeEnv" "production" -}}
{{- end -}}
{{- if not .Values.supervisor.service -}}
{{- $_ := set .Values.supervisor "service" dict -}}
{{- end -}}
{{- if not .Values.supervisor.service.type -}}
{{- $_ := set .Values.supervisor.service "type" "ClusterIP" -}}
{{- end -}}
{{- if not .Values.supervisor.service.port -}}
{{- $_ := set .Values.supervisor.service "port" 8020 -}}
{{- end -}}
{{- if not .Values.supervisor.env -}}
{{- $_ := set .Values.supervisor "env" dict -}}
{{- end -}}
{{- if not .Values.supervisor.podLabels -}}
{{- $_ := set .Values.supervisor "podLabels" dict -}}
{{- end -}}
{{- if not .Values.supervisor.podAnnotations -}}
{{- $_ := set .Values.supervisor "podAnnotations" dict -}}
{{- end -}}

{{/* Supervisor image defaults */}}
{{- if not .Values.supervisorImage -}}
{{- $_ := set .Values "supervisorImage" dict -}}
{{- end -}}
{{- if not .Values.supervisorImage.repository -}}
{{- $_ := set .Values.supervisorImage "repository" "ghcr.io/triggerdotdev/supervisor" -}}
{{- end -}}
{{- if not .Values.supervisorImage.tag -}}
{{- $_ := set .Values.supervisorImage "tag" "latest" -}}
{{- end -}}
{{- if not .Values.supervisorImage.digest -}}
{{- $_ := set .Values.supervisorImage "digest" "" -}}
{{- end -}}

{{/* Coordinator image defaults */}}
{{- if not .Values.coordinatorImage -}}
{{- $_ := set .Values "coordinatorImage" dict -}}
{{- end -}}
{{- if not .Values.coordinatorImage.repository -}}
{{- $_ := set .Values.coordinatorImage "repository" "ghcr.io/triggerdotdev/coordinator" -}}
{{- end -}}
{{- if not .Values.coordinatorImage.tag -}}
{{- $_ := set .Values.coordinatorImage "tag" "latest" -}}
{{- end -}}
{{- if not .Values.coordinatorImage.digest -}}
{{- $_ := set .Values.coordinatorImage "digest" "" -}}
{{- end -}}

{{/* Kubernetes provider image defaults */}}
{{- if not .Values.kubernetesProviderImage -}}
{{- $_ := set .Values "kubernetesProviderImage" dict -}}
{{- end -}}
{{- if not .Values.kubernetesProviderImage.repository -}}
{{- $_ := set .Values.kubernetesProviderImage "repository" "ghcr.io/triggerdotdev/provider/kubernetes" -}}
{{- end -}}
{{- if not .Values.kubernetesProviderImage.tag -}}
{{- $_ := set .Values.kubernetesProviderImage "tag" "latest" -}}
{{- end -}}
{{- if not .Values.kubernetesProviderImage.digest -}}
{{- $_ := set .Values.kubernetesProviderImage "digest" "" -}}
{{- end -}}

{{/* Quickstart defaults */}}
{{- if not .Values.quickstart -}}
{{- $_ := set .Values "quickstart" dict -}}
{{- end -}}
{{- if not .Values.quickstart.enabled -}}
{{- $_ := set .Values.quickstart "enabled" true -}}
{{- end -}}

{{/* Database defaults */}}
{{- if not .Values.database -}}
{{- $_ := set .Values "database" dict -}}
{{- end -}}
{{- if not .Values.database.externalHost -}}
{{- $_ := set .Values.database "externalHost" "localhost" -}}
{{- end -}}
{{- if not .Values.database.externalPort -}}
{{- $_ := set .Values.database "externalPort" 5432 -}}
{{- end -}}
{{- if not .Values.database.externalDatabase -}}
{{- $_ := set .Values.database "externalDatabase" "trigger" -}}
{{- end -}}
{{- if not .Values.database.externalUser -}}
{{- $_ := set .Values.database "externalUser" "trigger" -}}
{{- end -}}
{{- if not .Values.database.externalPassword -}}
{{- $_ := set .Values.database "externalPassword" "trigger" -}}
{{- end -}}

{{/* Database migration defaults */}}
{{- if not .Values.dbMigration -}}
{{- $_ := set .Values "dbMigration" dict -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration "enabled") -}}
{{- $_ := set .Values.dbMigration "enabled" true -}}
{{- end -}}
{{- if not .Values.dbMigration.jobAnnotations -}}
{{- $_ := set .Values.dbMigration "jobAnnotations" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.podAnnotations -}}
{{- $_ := set .Values.dbMigration "podAnnotations" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.podLabels -}}
{{- $_ := set .Values.dbMigration "podLabels" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.resources -}}
{{- $_ := set .Values.dbMigration "resources" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.resources.requests -}}
{{- $_ := set .Values.dbMigration.resources "requests" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.resources.limits -}}
{{- $_ := set .Values.dbMigration.resources "limits" dict -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.requests "cpu") -}}
{{- $_ := set .Values.dbMigration.resources.requests "cpu" "100m" -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.requests "memory") -}}
{{- $_ := set .Values.dbMigration.resources.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.limits "cpu") -}}
{{- $_ := set .Values.dbMigration.resources.limits "cpu" "500m" -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.limits "memory") -}}
{{- $_ := set .Values.dbMigration.resources.limits "memory" "512Mi" -}}
{{- end -}}

{{/* Redis defaults */}}
{{- if not .Values.redis -}}
{{- $_ := set .Values "redis" dict -}}
{{- end -}}
{{- if not .Values.redis.url -}}
{{- $_ := set .Values.redis "url" "redis://localhost:6379" -}}
{{- end -}}

{{/* Resources defaults */}}
{{- if not .Values.resources -}}
{{- $_ := set .Values "resources" dict -}}
{{- end -}}

{{/* Worker resources defaults */}}
{{- if not .Values.resources.worker -}}
{{- $_ := set .Values.resources "worker" dict -}}
{{- end -}}
{{- if not .Values.resources.worker.requests -}}
{{- $_ := set .Values.resources.worker "requests" dict -}}
{{- end -}}
{{- if not .Values.resources.worker.requests.cpu -}}
{{- $_ := set .Values.resources.worker.requests "cpu" "100m" -}}
{{- end -}}
{{- if not .Values.resources.worker.requests.memory -}}
{{- $_ := set .Values.resources.worker.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not .Values.resources.worker.limits -}}
{{- $_ := set .Values.resources.worker "limits" dict -}}
{{- end -}}
{{- if not .Values.resources.worker.limits.cpu -}}
{{- $_ := set .Values.resources.worker.limits "cpu" "500m" -}}
{{- end -}}
{{- if not .Values.resources.worker.limits.memory -}}
{{- $_ := set .Values.resources.worker.limits "memory" "512Mi" -}}
{{- end -}}

{{/* App resources defaults */}}
{{- if not .Values.resources.app -}}
{{- $_ := set .Values.resources "app" dict -}}
{{- end -}}
{{- if not .Values.resources.app.requests -}}
{{- $_ := set .Values.resources.app "requests" dict -}}
{{- end -}}
{{- if not .Values.resources.app.requests.cpu -}}
{{- $_ := set .Values.resources.app.requests "cpu" "100m" -}}
{{- end -}}
{{- if not .Values.resources.app.requests.memory -}}
{{- $_ := set .Values.resources.app.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not .Values.resources.app.limits -}}
{{- $_ := set .Values.resources.app "limits" dict -}}
{{- end -}}
{{- if not .Values.resources.app.limits.cpu -}}
{{- $_ := set .Values.resources.app.limits "cpu" "500m" -}}
{{- end -}}
{{- if not .Values.resources.app.limits.memory -}}
{{- $_ := set .Values.resources.app.limits "memory" "512Mi" -}}
{{- end -}}

{{/* Supervisor resources defaults */}}
{{- if not .Values.resources.supervisor -}}
{{- $_ := set .Values.resources "supervisor" dict -}}
{{- end -}}
{{- if not .Values.resources.supervisor.requests -}}
{{- $_ := set .Values.resources.supervisor "requests" dict -}}
{{- end -}}
{{- if not .Values.resources.supervisor.requests.cpu -}}
{{- $_ := set .Values.resources.supervisor.requests "cpu" "100m" -}}
{{- end -}}
{{- if not .Values.resources.supervisor.requests.memory -}}
{{- $_ := set .Values.resources.supervisor.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not .Values.resources.supervisor.limits -}}
{{- $_ := set .Values.resources.supervisor "limits" dict -}}
{{- end -}}
{{- if not .Values.resources.supervisor.limits.cpu -}}
{{- $_ := set .Values.resources.supervisor.limits "cpu" "500m" -}}
{{- end -}}
{{- if not .Values.resources.supervisor.limits.memory -}}
{{- $_ := set .Values.resources.supervisor.limits "memory" "512Mi" -}}
{{- end -}}

{{/* Autoscaling defaults */}}
{{- if not .Values.autoscaling -}}
{{- $_ := set .Values "autoscaling" dict -}}
{{- end -}}
{{- if not (hasKey .Values.autoscaling "enabled") -}}
{{- $_ := set .Values.autoscaling "enabled" false -}}
{{- end -}}
{{- if not .Values.autoscaling.minReplicas -}}
{{- $_ := set .Values.autoscaling "minReplicas" 1 -}}
{{- end -}}
{{- if not .Values.autoscaling.maxReplicas -}}
{{- $_ := set .Values.autoscaling "maxReplicas" 100 -}}
{{- end -}}
{{- if not .Values.autoscaling.targetCPUUtilizationPercentage -}}
{{- $_ := set .Values.autoscaling "targetCPUUtilizationPercentage" 80 -}}
{{- end -}}
{{- if not .Values.autoscaling.targetMemoryUtilizationPercentage -}}
{{- $_ := set .Values.autoscaling "targetMemoryUtilizationPercentage" 80 -}}
{{- end -}}

{{/* Database defaults */}}
{{- if not .Values.database -}}
{{- $_ := set .Values "database" dict -}}
{{- end -}}
{{- if not .Values.database.externalHost -}}
{{- $_ := set .Values.database "externalHost" "localhost" -}}
{{- end -}}
{{- if not .Values.database.externalPort -}}
{{- $_ := set .Values.database "externalPort" 5432 -}}
{{- end -}}
{{- if not .Values.database.externalDatabase -}}
{{- $_ := set .Values.database "externalDatabase" "trigger" -}}
{{- end -}}
{{- if not .Values.database.externalUser -}}
{{- $_ := set .Values.database "externalUser" "trigger" -}}
{{- end -}}
{{- if not .Values.database.externalPassword -}}
{{- $_ := set .Values.database "externalPassword" "trigger" -}}
{{- end -}}

{{/* Database migration defaults */}}
{{- if not .Values.dbMigration -}}
{{- $_ := set .Values "dbMigration" dict -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration "enabled") -}}
{{- $_ := set .Values.dbMigration "enabled" true -}}
{{- end -}}
{{- if not .Values.dbMigration.jobAnnotations -}}
{{- $_ := set .Values.dbMigration "jobAnnotations" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.podAnnotations -}}
{{- $_ := set .Values.dbMigration "podAnnotations" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.podLabels -}}
{{- $_ := set .Values.dbMigration "podLabels" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.resources -}}
{{- $_ := set .Values.dbMigration "resources" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.resources.requests -}}
{{- $_ := set .Values.dbMigration.resources "requests" dict -}}
{{- end -}}
{{- if not .Values.dbMigration.resources.limits -}}
{{- $_ := set .Values.dbMigration.resources "limits" dict -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.requests "cpu") -}}
{{- $_ := set .Values.dbMigration.resources.requests "cpu" "100m" -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.requests "memory") -}}
{{- $_ := set .Values.dbMigration.resources.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.limits "cpu") -}}
{{- $_ := set .Values.dbMigration.resources.limits "cpu" "500m" -}}
{{- end -}}
{{- if not (hasKey .Values.dbMigration.resources.limits "memory") -}}
{{- $_ := set .Values.dbMigration.resources.limits "memory" "512Mi" -}}
{{- end -}}

{{/* Redis defaults */}}
{{- if not .Values.redis -}}
{{- $_ := set .Values "redis" dict -}}
{{- end -}}
{{- if not .Values.redis.url -}}
{{- $_ := set .Values.redis "url" "redis://localhost:6379" -}}
{{- end -}}

{{/* Resources defaults */}}
{{- if not .Values.resources -}}
{{- $_ := set .Values "resources" dict -}}
{{- end -}}

{{/* Worker resources defaults */}}
{{- if not .Values.resources.worker -}}
{{- $_ := set .Values.resources "worker" dict -}}
{{- end -}}
{{- if not .Values.resources.worker.requests -}}
{{- $_ := set .Values.resources.worker "requests" dict -}}
{{- end -}}
{{- if not .Values.resources.worker.requests.cpu -}}
{{- $_ := set .Values.resources.worker.requests "cpu" "100m" -}}
{{- end -}}
{{- if not .Values.resources.worker.requests.memory -}}
{{- $_ := set .Values.resources.worker.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not .Values.resources.worker.limits -}}
{{- $_ := set .Values.resources.worker "limits" dict -}}
{{- end -}}
{{- if not .Values.resources.worker.limits.cpu -}}
{{- $_ := set .Values.resources.worker.limits "cpu" "500m" -}}
{{- end -}}
{{- if not .Values.resources.worker.limits.memory -}}
{{- $_ := set .Values.resources.worker.limits "memory" "512Mi" -}}
{{- end -}}

{{/* App resources defaults */}}
{{- if not .Values.resources.app -}}
{{- $_ := set .Values.resources "app" dict -}}
{{- end -}}
{{- if not .Values.resources.app.requests -}}
{{- $_ := set .Values.resources.app "requests" dict -}}
{{- end -}}
{{- if not .Values.resources.app.requests.cpu -}}
{{- $_ := set .Values.resources.app.requests "cpu" "100m" -}}
{{- end -}}
{{- if not .Values.resources.app.requests.memory -}}
{{- $_ := set .Values.resources.app.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not .Values.resources.app.limits -}}
{{- $_ := set .Values.resources.app "limits" dict -}}
{{- end -}}
{{- if not .Values.resources.app.limits.cpu -}}
{{- $_ := set .Values.resources.app.limits "cpu" "500m" -}}
{{- end -}}
{{- if not .Values.resources.app.limits.memory -}}
{{- $_ := set .Values.resources.app.limits "memory" "512Mi" -}}
{{- end -}}

{{/* Supervisor resources defaults */}}
{{- if not .Values.resources.supervisor -}}
{{- $_ := set .Values.resources "supervisor" dict -}}
{{- end -}}
{{- if not .Values.resources.supervisor.requests -}}
{{- $_ := set .Values.resources.supervisor "requests" dict -}}
{{- end -}}
{{- if not .Values.resources.supervisor.requests.cpu -}}
{{- $_ := set .Values.resources.supervisor.requests "cpu" "100m" -}}
{{- end -}}
{{- if not .Values.resources.supervisor.requests.memory -}}
{{- $_ := set .Values.resources.supervisor.requests "memory" "128Mi" -}}
{{- end -}}
{{- if not .Values.resources.supervisor.limits -}}
{{- $_ := set .Values.resources.supervisor "limits" dict -}}
{{- end -}}
{{- if not .Values.resources.supervisor.limits.cpu -}}
{{- $_ := set .Values.resources.supervisor.limits "cpu" "500m" -}}
{{- end -}}
{{- if not .Values.resources.supervisor.limits.memory -}}
{{- $_ := set .Values.resources.supervisor.limits "memory" "512Mi" -}}
{{- end -}}
{{- end -}}

{{/*
Validate required values
*/}}
{{- define "trigger-dev.validateValues" -}}
{{- include "trigger-dev.defaultValues" . -}}
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
Create chart name and version as used by the chart label
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
{{- default (include "trigger-dev.fullname" .) .Values.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- default "default" .Values.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the name of the app service
*/}}
{{- define "trigger-dev.app.name" -}}
{{- printf "%s-app" (include "trigger-dev.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the worker service
*/}}
{{- define "trigger-dev.worker.name" -}}
{{- printf "%s-worker" (include "trigger-dev.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the supervisor service
*/}}
{{- define "trigger-dev.supervisor.name" -}}
{{- printf "%s-supervisor" (include "trigger-dev.fullname" .) | trunc 63 | trimSuffix "-" }}
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

{{/*
Validate required secrets in quickstart mode
*/}}
{{- define "trigger-dev.validateSecrets" -}}
{{- if .Values.quickstart.enabled -}}
{{- if not .Values.secrets.magicLinkSecret -}}
{{- fail "A valid magicLinkSecret is required when quickstart.enabled is true" -}}
{{- end -}}
{{- if not .Values.secrets.encryptionKey -}}
{{- fail "A valid encryptionKey is required when quickstart.enabled is true" -}}
{{- end -}}
{{- if not .Values.secrets.workerToken -}}
{{- fail "A valid workerToken is required when quickstart.enabled is true" -}}
{{- end -}}
{{- if not .Values.secrets.managedWorkerSecret -}}
{{- fail "A valid managedWorkerSecret is required when quickstart.enabled is true" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate environment variables
*/}}
{{- define "trigger-dev.validateEnv" -}}
{{- if .Values.worker.env -}}
{{- range $key, $value := .Values.worker.env }}
{{- if not $value }}
{{- fail (printf "Environment variable %s cannot be empty" $key) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}} 