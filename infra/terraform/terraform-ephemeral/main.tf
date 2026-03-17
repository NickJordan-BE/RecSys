# main.tf
data "aws_caller_identity" "current" {}
# resource "kubernetes_secret" "dockerhub-auth" {
#     for_each = toset(local.targeted_namespaces)
#     metadata {
#         name = "dockerhub-auth"
#         namespace = each.value
#     }

#     type = "kubernetes.io/dockerconfigjson"

#     data = {
#         ".dockerconfigjson" = jsonencode(local.docker_config)
#     }
# }