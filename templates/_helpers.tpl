apiVersion: v2
name: k8s-access-manager
description: A Helm chart for managing Kubernetes RBAC access with token-based authentication
type: application
version: 0.1.0
appVersion: "1.0.0"

dependencies: []

maintainers:
  - name: EvgenyAdlerberg
    email: adlerbergevgeny@gmail.com

annotations:
  category: RBAC
  description: "Manages user access with service account tokens"

{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-access-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "k8s-access-manager.fullname" -}}
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
{{- define "k8s-access-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-access-manager.labels" -}}
helm.sh/chart: {{ include "k8s-access-manager.chart" . }}
{{ include "k8s-access-manager.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-access-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-access-manager.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Get ServiceAccount name for user
*/}}
{{- define "k8s-access-manager.serviceAccountName" -}}
{{- $username := .username -}}
{{- $userConfig := .userConfig -}}
{{- if $userConfig.serviceAccountName -}}
{{- $userConfig.serviceAccountName -}}
{{- else -}}
{{- $username | lower | replace " " "-" -}}
{{- end -}}
{{- end -}}

{{/*
Should create token secret for user
*/}}
{{- define "k8s-access-manager.createTokenSecret" -}}
{{- $userConfig := .userConfig -}}
{{- $global := .global -}}
{{- if hasKey $userConfig "createTokenSecret" -}}
{{- $userConfig.createTokenSecret -}}
{{- else -}}
{{- $global.createTokenSecrets -}}
{{- end -}}
{{- end -}}

{{/*
Determine role type: custom, k8s, or our
*/}}
{{- define "k8s-access-manager.roleType" -}}
{{- $roleName := .roleName -}}
{{- if hasPrefix "custom:" $roleName -}}
"custom"
{{- else if hasPrefix "k8s:" $roleName -}}
"k8s"
{{- else -}}
"our"
{{- end -}}
{{- end -}}

{{/*
Get actual role name (without prefix)
*/}}
{{- define "k8s-access-manager.actualRoleName" -}}
{{- $roleName := .roleName -}}
{{- if hasPrefix "custom:" $roleName -}}
{{- trimPrefix "custom:" $roleName -}}
{{- else if hasPrefix "k8s:" $roleName -}}
{{- trimPrefix "k8s:" $roleName -}}
{{- else -}}
{{- $roleName -}}
{{- end -}}
{{- end -}}