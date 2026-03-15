{{/*
Common helper functions for the workastra chart.
*/}}

{{- define "workastra.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "workastra.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "workastra.labels" -}}
helm.sh/chart: {{ include "workastra.chart" . }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Desk service helpers
*/}}
{{- define "workastra.desk.fullname" -}}
{{- printf "%s-desk" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "workastra.desk.selectorLabels" -}}
app.kubernetes.io/name: desk
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: desk
{{- end }}

{{- define "workastra.desk.labels" -}}
helm.sh/chart: {{ include "workastra.chart" . }}
{{ include "workastra.desk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
IAM service helpers
*/}}
{{- define "workastra.iam.fullname" -}}
{{- printf "%s-iam" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "workastra.iam.selectorLabels" -}}
app.kubernetes.io/name: iam
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: iam
{{- end }}

{{- define "workastra.iam.labels" -}}
helm.sh/chart: {{ include "workastra.chart" . }}
{{ include "workastra.iam.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Migration service helpers
*/}}
{{- define "workastra.migration.fullname" -}}
{{- printf "%s-migration" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "workastra.migration.selectorLabels" -}}
app.kubernetes.io/name: migration
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: migration
{{- end }}

{{- define "workastra.migration.labels" -}}
helm.sh/chart: {{ include "workastra.chart" . }}
{{ include "workastra.migration.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
