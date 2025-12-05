variable "cluster_name" {
  description = "Назва EKS кластера"
  type        = string
}

variable "kubernetes_version" {
  description = "Версія Kubernetes для EKS"
  type        = string
  default     = "1.28"
}

variable "vpc_id" {
  description = "ID VPC для розміщення EKS"
  type        = string
}

variable "subnet_ids" {
  description = "Список ID підмереж для EKS (приватні підмережі)"
  type        = list(string)
}

variable "instance_types" {
  description = "Типи EC2 інстансів для worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_nodes" {
  description = "Бажана кількість worker nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Мінімальна кількість worker nodes"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Максимальна кількість worker nodes"
  type        = number
  default     = 3
}
