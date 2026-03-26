locals {
  namespaces = [
    "orchestrator-app",
    "feature-store-app",
    "candidate-generation-app",
    "filtering-app",
    "ranking-app"
  ]
}

resource "kubernetes_namespace_v1" "app_namespace" {
  for_each = toset(local.namespaces)
  metadata {
    name = each.value
    
    labels = {
      name        = each.value
      environment = "production"
    }
  }

  depends_on = [ module.eks ]
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  set = [
    {
    name  = "clusterName"
    value = module.eks.cluster_name
    },
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.load_balancer_controller_irsa_role.arn
    }
  ]

  depends_on = [module.eks, module.load_balancer_controller_irsa_role]
}

resource "helm_release" "argo_cd_controller" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "4.5.2"

  namespace        = "argocd"
  create_namespace = true

  depends_on = [module.eks, helm_release.aws_load_balancer_controller]
}
