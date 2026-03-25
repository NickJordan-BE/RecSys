

resource "aws_iam_openid_connect_provider" "github_actions_ecr_push" {
  url = "https://token.actions.githubusercontent.com" 
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    "ffffffffffffffffffffffffffffffffffffffff", 
  ]
}

data "aws_iam_policy_document" "oidc_trust_policy" {
    statement{
        effect = "Allow"
        principals {
            type = "Federated"
            identifiers = [aws_iam_openid_connect_provider.github_actions_ecr_push.arn]
        }
        actions = ["sts:AssumeRoleWithWebIdentity"]
        condition {
            test = "StringEquals"
            variable = "token.actions.githubusercontent.com:aud"
            values = ["sts.amazonaws.com"]
        }
        condition {
            test = "StringLike"
            variable = "token.actions.githubusercontent.com:sub"
            values = ["repo:NickJordan-BE/RecSys:*"]
        }
    }
}


resource "aws_iam_role" "github_actions_ecr_push" {
  name = "Recsys-Github-Actions-ECR-Role"
  assume_role_policy = data.aws_iam_policy_document.oidc_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  role       = aws_iam_role.github_actions_ecr_push.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}


resource "aws_iam_role_policy" "github_actions_ecr_push" {
  name = "Github-Actions-ECR-Push"
  role = aws_iam_role.github_actions_ecr_push.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
        ]
        Resource = "*"
      }
    ]
  })
}