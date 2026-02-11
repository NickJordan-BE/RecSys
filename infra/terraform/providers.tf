terraform {
    required_providers {
    kind = {
            source = "tehcyx/kind"
            version = "0.4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.29.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
  }

  required_version = ">= 1.5.0"
}
provider "kind" {}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}

resource "local_file" "kubeconfig" {
  content  = kind_cluster.recsys-cluster-3.kubeconfig
  filename = "${path.module}/kubeconfig.yaml"
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}
