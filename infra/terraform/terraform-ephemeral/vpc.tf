# vpc.tf 

locals {
    cluster_name = "prod-eks-cluster"
    cidr = "10.0.0.0/16"
    region = "us-west-2"
}

data "aws_iam_policy_document" "s3_ecr_access" {
  statement {
    sid    = "AllowECRImageLayerDownloads"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    # Use specific buckets for ecr
    resources = [
      "arn:aws:s3:::prod-${local.region}-starport-layer-bucket/*"
    ]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  providers = {
    aws = aws.network_admin
  }

  name = local.cluster_name
  cidr = local.cidr
  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  # Set to false in high availability production
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  provider = aws.network_admin
  
  name        = "${local.cluster_name}-vpc-endpoints-sg"
  description = "Security group for ECR VPC Endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.cidr]
  }

  tags = {
    Name = "${local.cluster_name}-vpc-endpoints-sg"
  }
}

resource "aws_vpc_endpoint" "s3" {
  provider = aws.network_admin

  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = module.vpc.private_route_table_ids
  policy = data.aws_iam_policy_document.s3_ecr_access.json
}


resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  provider = aws.network_admin
  
  vpc_id       = module.vpc.vpc_id
  private_dns_enabled = true
  service_name = "com.amazonaws.${local.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoints.id] 
  subnet_ids = module.vpc.private_subnets
}

resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  provider = aws.network_admin
  
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.vpc_endpoints.id] 
  subnet_ids = module.vpc.private_subnets
}