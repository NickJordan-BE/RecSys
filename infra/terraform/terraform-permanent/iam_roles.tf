# iam_roles.tf

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_admin_trust" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
          type = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/recsys-terraform-admin"]
        }
    }
}


resource "aws_iam_role" "network_provisioning" {
    name = "Recsys-Network-Provisioning-Role"
    assume_role_policy = data.aws_iam_policy_document.terraform_admin_trust.json
}

resource "aws_iam_role_policy_attachment" "networking_admin" {
    role = aws_iam_role.network_provisioning.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role" "eks_provisioning" {
    name = "Recsys-EKS-Provisioning-Role"
    assume_role_policy = data.aws_iam_policy_document.terraform_admin_trust.json
}

resource "aws_iam_role_policy_attachment" "eks_admin" {
    role = aws_iam_role.eks_provisioning.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy" "network_eip_fix" {
  name = "EIP-Describe-Fix"
  role = aws_iam_role.network_provisioning.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeAddressesAttribute"]
        Resource = "*"
      }
    ]
  })
}