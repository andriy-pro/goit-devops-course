# ===========================================
# Outputs для модуля моніторингу
# ===========================================

output "prometheus_namespace" {
  description = "Namespace де встановлено Prometheus"
  value       = helm_release.prometheus.namespace
}

output "grafana_namespace" {
  description = "Namespace де встановлено Grafana"
  value       = helm_release.grafana.namespace
}

output "prometheus_service" {
  description = "Назва сервісу Prometheus"
  value       = "prometheus-server"
}

output "grafana_service" {
  description = "Назва сервісу Grafana"
  value       = "grafana"
}

