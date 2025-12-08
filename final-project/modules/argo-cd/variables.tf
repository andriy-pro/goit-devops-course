variable "eks_dependency" {
  description = "EKS cluster dependency"
  type        = any
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace для Argo CD"
  type        = string
  default     = "argocd"
}
