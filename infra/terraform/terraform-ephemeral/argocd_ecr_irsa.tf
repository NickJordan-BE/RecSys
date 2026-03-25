
module "argocd_ecr_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.4.0"
  name    = "Recsys-Argocd-ECR-Role"

  providers = {
    aws = aws.eks_admin
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argocd:argocd-ecr-sa"]
    }
  }

  policies = {
    policy = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
}