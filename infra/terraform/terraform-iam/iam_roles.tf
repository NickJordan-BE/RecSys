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
    name = "Network-Provisioning-Role"
    assume_role_policy = data.aws_iam_policy_document.terraform_admin_trust.json
}

resource "aws_iam_policy_attachment" "networking_admin" {
    name = "network-attachment"
    roles = [aws_iam_role.network_provisioning.name]
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role" "eks_provisioning" {
    name = "EKS-Provisioning-Role"
    assume_role_policy = data.aws_iam_policy_document.terraform_admin_trust.json
}

resource "aws_iam_policy_attachment" "eks_admin" {
    name = "eks-attachment"
    roles = [aws_iam_role.eks_provisioning.name]
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}