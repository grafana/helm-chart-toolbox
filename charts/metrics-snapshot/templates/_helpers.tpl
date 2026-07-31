{{/*
Expand the name of the chart.
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.fullname" -}}
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
{{- define "helm-chart-toolbox.metrics-snapshot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.labels" -}}
helm.sh/chart: {{ include "helm-chart-toolbox.metrics-snapshot.chart" . }}
{{ include "helm-chart-toolbox.metrics-snapshot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm-chart-toolbox.metrics-snapshot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
The fully qualified test pod image reference.
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.image" -}}
{{- printf "%s/%s:%s" (.Values.global.image.registry | default .Values.image.registry) .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/*
The image pull secrets, if any are configured (global takes precedence).
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.imagePullSecrets" -}}
{{- if .Values.global.image.pullSecrets }}
{{- toYaml .Values.global.image.pullSecrets }}
{{- else }}
{{- toYaml .Values.image.pullSecrets }}
{{- end }}
{{- end }}

{{/*
The envFrom entries for a test pod: the generated Secret (when env is set) plus any
user-supplied envFrom references.
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.envFrom" -}}
{{- if .Values.env }}
- secretRef:
    name: {{ include "helm-chart-toolbox.metrics-snapshot.fullname" . }}
{{- end }}
{{- with .Values.envFrom }}
{{- toYaml . }}
{{- end }}
{{- end }}
