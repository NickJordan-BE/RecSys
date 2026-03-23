# S3 backend needs to be provisioned via AWS CLI or UI
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.36"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }

  backend "s3" {
    bucket       = "recsys-terraform-state-bucket"
    key          = "dev/main/state/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }

  required_version = "1.14.7"
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "eks_admin"
  region = "us-west-2"

  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Recsys-EKS-Provisioning-Role"
    session_name = "Terraform-EKS-Provisioning"
  }
}

provider "aws" {
  alias  = "network_admin"
  region = "us-west-2"

  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Recsys-Network-Provisioning-Role"
    session_name = "Terraform-Network-Provisioning"
  }
}

provider "aws" {
  alias  = "elasticache_admin"
  region = "us-west-2"

  assume_role {
    role_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Recsys-Elasticache-Provisioning-Role"
    session_name = "Terraform-Elasticache-Provisioning"
  }
}
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name", module.eks.cluster_name,
        "--role-arn", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Recsys-EKS-Provisioning-Role"
      ]
    }
  }
}
