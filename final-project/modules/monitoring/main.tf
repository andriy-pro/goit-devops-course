# ===========================================
# Модуль моніторингу: Prometheus + Grafana
# ===========================================
# Встановлення через Helm charts

# --- Prometheus ---
# Збір метрик з усіх компонентів кластера
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "monitoring"
  create_namespace = true
  version          = "25.8.0" # https://github.com/prometheus-community/helm-charts/releases

  values = [file("${path.module}/values-prometheus.yaml")]

  # Чекаємо поки EKS буде готовий
  depends_on = [var.eks_dependency]
}

# --- Grafana ---
# Візуалізація метрик та дашборди
resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "monitoring"
  create_namespace = true
  version          = "7.0.0" # https://github.com/grafana/helm-charts/releases

  values = [file("${path.module}/values-grafana.yaml")]

  # Grafana встановлюється після Prometheus
  depends_on = [helm_release.prometheus]
}

