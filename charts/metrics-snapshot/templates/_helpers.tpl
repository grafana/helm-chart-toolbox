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
Renders a test Pod. Expects a dict with:
  root         - the root context ($)
  mode         - "generate" or "compare"
  weight       - the helm hook weight (controls ordering)
  withBaseline - whether to mount the baseline snapshot
*/}}
{{- define "helm-chart-toolbox.metrics-snapshot.testPod" -}}
{{- $ := .root -}}
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "helm-chart-toolbox.metrics-snapshot.fullname" $ }}-{{ .mode }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "helm-chart-toolbox.metrics-snapshot.labels" $ | nindent 4 }}
    {{- range $key, $val := $.Values.pod.extraLabels }}
    {{ $key }}: {{ $val | quote }}
    {{- end }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation
    "helm.sh/hook-weight": {{ .weight | quote }}
    {{- range $key, $val := $.Values.pod.extraAnnotations }}
    {{ $key }}: {{ $val | quote }}
    {{- end }}
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  {{- if $.Values.pod.serviceAccount.name }}
  serviceAccountName: {{ $.Values.pod.serviceAccount.name }}
  {{- end }}
  {{- if or $.Values.global.image.pullSecrets $.Values.image.pullSecrets }}
  imagePullSecrets:
    {{- if $.Values.global.image.pullSecrets }}
    {{- toYaml $.Values.global.image.pullSecrets | nindent 8 }}
    {{- else }}
    {{- toYaml $.Values.image.pullSecrets | nindent 8 }}
    {{- end }}
  {{- end }}
  restartPolicy: Never
  {{- with $.Values.pod.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- with $.Values.pod.tolerations }}
  tolerations:
    {{- toYaml . | nindent 8 }}
  {{- end }}
  {{- if $.Values.initialDelay }}
  initContainers:
    - name: wait
      image: {{ include "helm-chart-toolbox.metrics-snapshot.image" $ | quote }}
      command: ["bash", "-c", "sleep {{ $.Values.initialDelay | int }}"]
  {{- end }}
  containers:
    - name: metrics-snapshot
      image: {{ include "helm-chart-toolbox.metrics-snapshot.image" $ | quote }}
      command:
        - bash
        - -c
        - |
          for i in $(seq 1 {{ $.Values.attempts | int }}); do
            echo "Running {{ .mode }} test... ($i/{{ $.Values.attempts | int }})"
            /usr/bin/metrics-snapshot.sh {{ .mode }} /etc/config/config.json{{ if .withBaseline }} /etc/baseline/baseline.yaml{{ end }}
            code=$?
            if [ ${code} -eq 0 ]; then exit 0; fi
            if [ ${code} -eq 1 ]; then exit 1; fi
            sleep {{ $.Values.delay | int }}
          done
          exit 1
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
        readOnlyRootFilesystem: true
        seccompProfile:
          type: RuntimeDefault
      {{- if $.Values.env }}
      envFrom:
        - secretRef:
            name: {{ include "helm-chart-toolbox.metrics-snapshot.fullname" $ }}
        {{- with $.Values.envFrom }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- else if $.Values.envFrom }}
      envFrom:
        {{- toYaml $.Values.envFrom | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/config
        {{- if .withBaseline }}
        - name: baseline
          mountPath: /etc/baseline
        {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ include "helm-chart-toolbox.metrics-snapshot.fullname" $ }}
    {{- if .withBaseline }}
    - name: baseline
      configMap:
        name: {{ include "helm-chart-toolbox.metrics-snapshot.fullname" $ }}-baseline
    {{- end }}
{{- end }}
