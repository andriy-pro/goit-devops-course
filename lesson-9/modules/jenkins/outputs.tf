output "jenkins_namespace" {
  description = "Namespace де встановлено Jenkins"
  value       = helm_release.jenkins.namespace
}

output "jenkins_admin_password" {
  description = "Пароль адміністратора Jenkins"
  value       = data.kubernetes_secret.jenkins.data["jenkins-admin-password"]
  sensitive   = true
}

output "jenkins_release_name" {
  description = "Helm release name"
  value       = helm_release.jenkins.name
}