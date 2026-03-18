# ecr.tf 

locals {
    ecr_repositories = [
        "recsys/orchestrator",
        "recsys/feature-store",
        "recsys/filtering",
        "recsys/ranking",
        "recsys/recommendation-engine-umbrella-chart"
    ]
}

resource "aws_ecr_repository" "recys_repos" {
    for_each = toset(local.ecr_repositories)

    name = each.value
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
      scan_on_push = true
    }
}

resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
    for_each = aws_ecr_repository.recys_repos

    repository = each.value.name

    policy = jsonencode({
        rules = [{
            rulePriority = 1
            description = "Keep storage costs minimal by deleting untagged images older than 3 days."
            selection = {
                tagStatus = "untagged"
                countType = "sinceImagePushed"
                countUnit = "days"
                countNumber = 3
            }
            action = {
                type = "expire"
            }
        }]
    })
}