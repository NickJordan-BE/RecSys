resource "kind_cluster" "recsys-cluster-3" {
    name            = "recsys-cluster-3"
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

resource "helm_release" "orchestrator-app" {
    name  = "orchestrator-app"
    chart = "${path.module}/../helm/charts/orchestrator-app"
    namespace = kubernetes_namespace.orchestrator-app.metadata[0].name

    values = [
      file("${path.module}/../helm/charts/orchestrator-app/values.yaml")
    ]

    set {
      name = "image.repository"
      value = "${var.docker_username}/recsys"
    }
}