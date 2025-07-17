{{/*
Expand the name of the chart.
*/}}
{{- define "helm-chart-toolbox.kubernetes-objects-test.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm-chart-toolbox.kubernetes-objects-test.fullname" -}}
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
{{- define "helm-chart-toolbox.kubernetes-objects-test.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm-chart-toolbox.kubernetes-objects-test.labels" -}}
helm.sh/chart: {{ include "helm-chart-toolbox.kubernetes-objects-test.chart" . }}
{{ include "helm-chart-toolbox.kubernetes-objects-test.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm-chart-toolbox.kubernetes-objects-test.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm-chart-toolbox.kubernetes-objects-test.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm-chart-toolbox.kubernetes-objects-test.serviceAccountName" -}}
{{- if .Values.pod.serviceAccount.create }}
{{- default (include "helm-chart-toolbox.kubernetes-objects-test.fullname" .) .Values.pod.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.pod.serviceAccount.name }}
{{- end }}
{{- end }}
