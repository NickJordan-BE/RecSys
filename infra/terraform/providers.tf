# S3 backend needs to be provisioned via AWS CLI or UI
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.36"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 3.0.1"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.7.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.1"
    }
  }

  backend "s3" {
    bucket = "recsys-terraform-state-bucket"
    key = "dev/state/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
    use_lockfile = true
  }

  required_version = ">= 1.14.7"
}

# provider "helm" {
#   kubernetes = {
#     config_path = local_file.kubeconfig.filename
#   }
# }

# provider "kubernetes" {
#   config_path = local_file.kubeconfig.filename
# }
