# Jenkins Helm Release
# Актуальна версія: https://github.com/jenkinsci/helm-charts/releases
resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.8.110"
  namespace        = var.namespace
  create_namespace = true

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      controller = {
        # Використовуємо JDK21 (LTS) - нова структура для версії 5.x
        image = {
          tag = "lts-jdk21"
        }

        serviceType = "LoadBalancer"

        # Плагіни оновлюються автоматично при старті
        installPlugins = [
          "kubernetes:latest",
          "workflow-aggregator:latest",
          "git:latest",
          "configuration-as-code:latest",
          "pipeline-aws:latest"
        ]

        JCasC = {
          configScripts = {
            welcome-message = <<-EOT
              jenkins:
                systemMessage: "Jenkins for Lesson 9 CI/CD"
            EOT
          }
        }
      }

      agent = {
        enabled = true
        image = {
          repository = "jenkins/inbound-agent"
          tag        = "latest"
        }
      }

      # Persistence вимкнено (EKS потребує EBS CSI driver)
      # Для production потрібно встановити aws-ebs-csi-driver
      persistence = {
        enabled = false
      }
    })
  ]

  depends_on = [var.eks_dependency]
}

# Отримання пароля Jenkins
data "kubernetes_secret" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
  }

  depends_on = [helm_release.jenkins]
}