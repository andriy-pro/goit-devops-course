# ===========================================
# EBS CSI Driver для EKS
# ===========================================
# Потрібен для динамічного створення PersistentVolumes
# https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html

# --- EBS CSI Driver Addon ---
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  # Версія addon (auto-update)
  # addon_version = "v1.25.0-eksbuild.1"

  # IAM role для EBS CSI driver
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  # Чекаємо поки Node Group буде готова
  depends_on = [aws_eks_node_group.main]

  tags = {
    Name = "${var.cluster_name}-ebs-csi-driver"
  }
}

# --- IAM Role для EBS CSI Driver ---
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.cluster_name}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-ebs-csi-driver-role"
  }
}

# --- Attach policy для EBS CSI Driver ---
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# --- OIDC Provider для EKS ---
# Потрібен для IRSA (IAM Roles for Service Accounts)
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-oidc-provider"
  }
}

