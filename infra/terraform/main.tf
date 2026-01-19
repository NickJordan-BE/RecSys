resource "kind_cluster" "recsys-cluster-1" {
    name            = "recsys-cluster-1"
    node_image      = "kindest/node:v1.27.1"
    kubeconfig_path = pathexpand("/tmp/config")
    wait_for_ready  = true

    kind_config {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      node {
          role = "control-plane"
          extra_port_mappings {
              container_port = 80
              host_port      = 80
          }
      }

      node {
          role = "worker"
      }
  }
}

resource "kubernetes_namespace" "orchestrator-app" {
    metadata {
        name = "orchestrator-app"
    }
}

resource "kubernetes_secret" "dockerhub-auth" {
    for_each = toset(local.targeted_namespaces)
    metadata {
        name = "dockerhub-auth"
        namespace = each.value
    }

    type = "kubernetes.io/dockerconfigjson"

    data = {
        ".dockerconfigjson" = jsonencode(local.docker_config)
    }
}

resource "kubernetes_deployment" "orchestrator_app" {
  metadata {
    name      = "orchestrator-app"
    namespace = "orchestrator-app"
    labels = {
      app = "orchestrator-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "orchestrator-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "orchestrator-app"
        }
      }

      spec {
        image_pull_secrets {
          name = "dockerhub-auth"
        }

        container {
          name  = "orchestrator-app"
          image = "${var.docker_username}/recsys:spring-orchestrator-servicev1.0"
          image_pull_policy = "Always"

          port {
            container_port = 8080
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}
