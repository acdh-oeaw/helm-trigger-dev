{{/*
Generate random secrets for quickstart mode
*/}}
{{- define "trigger-dev.generateSecrets" -}}
{{- if .Values.quickstart.enabled -}}
{{- if not (lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" (include "trigger-dev.fullname" .))) -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s-secrets" (include "trigger-dev.fullname" .) }}
  namespace: {{ .Values.namespace | default .Release.Namespace }}
  labels:
    {{- include "trigger-dev.labels" . | nindent 4 }}
type: Opaque
data:
  SESSION_SECRET: {{ randAlphaNum 32 | b64enc }}
  MAGIC_LINK_SECRET: {{ randAlphaNum 32 | b64enc }}
  ENCRYPTION_KEY: {{ randAlphaNum 32 | b64enc }}
  TRIGGER_WORKER_TOKEN: {{ randAlphaNum 32 | b64enc }}
  MANAGED_WORKER_SECRET: {{ randAlphaNum 32 | b64enc }}
{{- end -}}
{{- end -}}
{{- end -}} 
