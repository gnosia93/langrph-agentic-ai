# ============================================
# Karpenter Helm Install
# ============================================

resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.11.0"
  namespace  = "karpenter"
  create_namespace = true

  set {
    name  = "settings.clusterName"
    value = aws_eks_cluster.main.name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = aws_eks_cluster.main.endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  depends_on = [
    aws_eks_node_group.system,
    aws_iam_role_policy_attachment.karpenter_policy,
    aws_iam_role_policy_attachment.karpenter_controller,
  ]
}
