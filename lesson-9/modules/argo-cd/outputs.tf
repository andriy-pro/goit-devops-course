output "argocd_namespace" {
  description = "Namespace де встановлено Argo CD"
  value       = helm_release.argocd.namespace
}

output "argocd_admin_password" {
  description = "Початковий пароль admin для Argo CD"
  value       = data.kubernetes_secret.argocd_admin.data["password"]
  sensitive   = true
}

output "argocd_release_name" {
  description = "Helm release name"
  value       = helm_release.argocd.name
}
