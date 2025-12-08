variable "eks_dependency" {
  description = "EKS cluster dependency (для depends_on)"
  type        = any
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace для Jenkins"
  type        = string
  default     = "jenkins"
}