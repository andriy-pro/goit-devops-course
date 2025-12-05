# Argo CD Helm Release
# Актуальна версія: helm search repo argo/argo-cd --versions
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.1.6"
  namespace        = var.namespace
  create_namespace = true

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
        extraArgs = ["--insecure"]
      }

      configs = {
        params = {
          "server.insecure" = true
        }
      }
    })
  ]

  depends_on = [var.eks_dependency]
}

# Отримання початкового пароля Argo CD
data "kubernetes_secret" "argocd_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }

  depends_on = [helm_release.argocd]
}
