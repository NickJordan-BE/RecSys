# locals {
#     targeted_namespaces = ["orchestrator-app"]


#     docker_config = {
#         auths = {
#             "https://index.docker.io/v1/" = {
#                 username = var.docker_username
#                 password = var.docker_token
#                 email    = var.docker_email
#                 auth = base64encode("${var.docker_username}:${var.docker_token}")
#             }
#         }
#     }
# }