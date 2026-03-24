# elasticache.tf

module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "1.11.0"

  providers = {
    aws = aws.elasticache_admin
  }

  # Configuration
  replication_group_id = "recsys-prod-redis-cache"
  description          = "Production cache for high throughput feature serving"
  engine_version       = "7.0"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  port                 = 6379


  # Cluster mode Configuration
  cluster_mode_enabled    = true
  num_node_groups         = 3
  replicas_per_node_group = 1

  # Security and Resillience settings   
  automatic_failover_enabled = true
  multi_az_enabled           = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true


  maintenance_window = "sun:05:00-sun:09:00"
  apply_immediately  = true

  # Networking
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  create_security_group = true
  security_group_name   = "recsys-redis-sg"
  security_group_rules = {
    ingress_eks = {
      description                  = "EKS Worker Node Traffics"
      from_port                    = 6379
      to_port                      = 6379
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.eks.node_security_group_id
    }
  }


  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}