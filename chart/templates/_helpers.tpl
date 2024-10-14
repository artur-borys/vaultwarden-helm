{{/*
Expand the name of the chart.
*/}}
{{- define "vaultwarden.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vaultwarden.fullname" -}}
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
{{- define "vaultwarden.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vaultwarden.labels" -}}
helm.sh/chart: {{ include "vaultwarden.chart" . }}
{{ include "vaultwarden.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vaultwarden.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vaultwarden.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vaultwarden.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vaultwarden.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Value for DB password - from values or existing secret
*/}}
{{- define "vaultwarden.dbPassword" -}}
{{- if .Values.global.database.existingSecret }}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace .Values.global.database.existingSecret) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- default .Values.global.database.password (get $secretData "mariadb-password" | b64dec)}}
{{- else }}
{{- .Values.global.database.password }}
{{- end }}
{{- end }}

{{/*
Admin token secret name
*/}}
{{- define "vaultwarden.adminTokenSecretName" }}
{{- default (printf "%s-admin-token" (include "vaultwarden.fullname" .)) .Values.auth.admin.existingSecret }}
{{- end }}

{{/*
SMTP secret name
*/}}
{{- define "vaultwarden.smtpSecretName" }}
{{- default (printf "%s-smtp" (include "vaultwarden.fullname" .)) .Values.smtp.existingSecret }}
{{- end }}

{{/*
MariaDB service name
*/}}
{{- define "vaultwarden.mariadbServiceName" }}
{{- if eq .Values.mariadb.architecture "standalone" }}
{{- printf "%s-mariadb" (include "vaultwarden.fullname" .) }}
{{- else }}
{{- printf "%s-mariadb-primary" (include "vaultwarden.fullname" .) }}
{{- end }}
{{- end }}

{{/*
TLS secret name
*/}}
{{- define "vaultwarden.tlsSecretName" }}
{{- default (printf "%s-tls" (include "vaultwarden.fullname" .)) .Values.tls.existingSecret }}
{{- end }}

{{/* Liveness probe */}}
{{- define "vaultwarden.livenessProbe" }}
{{- if .Values.livenessProbeOverride }}
{{- .Values.livenessProbeOverride | toYaml }}
{{- else }}
httpGet:
  path: /
  port: http
  scheme: {{ if or .Values.tls.existingSecret .Values.tls.certManager.enabled }}{{ "HTTPS" }}{{ else }}{{ "HTTP" }}{{ end }}
initialDelaySeconds: 30
periodSeconds: 10
timeoutSeconds: 3
failureThreshold: 3
successThreshold: 1
{{- end }}
{{- end }}

{{/* Readiness probe */}}
{{- define "vaultwarden.readinessProbe" }}
{{- if .Values.readinessProbeOverride }}
{{- .Values.readinessProbeOverride | toYaml }}
{{- else }}
httpGet:
  path: /
  port: http
  scheme: {{ if or .Values.tls.existingSecret .Values.tls.certManager.enabled }}{{ "HTTPS" }}{{ else }}{{ "HTTP" }}{{ end }}
initialDelaySeconds: 30
periodSeconds: 10
timeoutSeconds: 3
failureThreshold: 3
successThreshold: 1
{{- end }}
{{- end }}
