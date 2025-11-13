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
  }

  required_version = ">= 1.5.0"
        }
provider "kind" {}

resource "local_file" "kubeconfig" {
  content  = kind_cluster.recsys-kind-cluster.kubeconfig
  filename = "${path.module}/kubeconfig.yaml"
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}
