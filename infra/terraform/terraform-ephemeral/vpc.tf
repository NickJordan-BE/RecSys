# vpc.tf 

locals {
    cluster_name = "prod-eks-cluster"
    cidr = "10.0.0.0/16"
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