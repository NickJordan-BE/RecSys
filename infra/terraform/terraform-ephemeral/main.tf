resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2" 

  values = [
    <<-EOT
      clusterName: ${module.eks.cluster_name}
      serviceAccount:
        create: true
        name: aws-load-balancer-controller
        annotations:
          eks.amazonaws.com/role-arn: ${module.load_balancer_controller_irsa_role.arn}
    EOT
  ]

  depends_on = [module.eks]
}

