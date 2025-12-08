# ===========================================
# Змінні для модуля моніторингу
# ===========================================

variable "eks_dependency" {
  description = "Залежність від EKS модуля для правильного порядку створення"
  type        = any
}

variable "prometheus_version" {
  description = "Версія Helm chart для Prometheus"
  type        = string
  default     = "25.8.0"
}

variable "grafana_version" {
  description = "Версія Helm chart для Grafana"
  type        = string
  default     = "7.0.0"
}

variable "namespace" {
  description = "Kubernetes namespace для моніторингу"
  type        = string
  default     = "monitoring"
}

