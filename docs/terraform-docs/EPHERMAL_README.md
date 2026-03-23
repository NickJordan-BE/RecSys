## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.14.7)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 6.36)

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (>= 3.1.1)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (>= 3.0.1)

- <a name="requirement_local"></a> [local](#requirement\_local) (>= 2.7.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (6.36.0)

- <a name="provider_aws.network_admin"></a> [aws.network\_admin](#provider\_aws.network\_admin) (6.36.0)

## Modules

The following Modules are called:

### <a name="module_eks"></a> [eks](#module\_eks)

Source: terraform-aws-modules/eks/aws

Version: ~> 21.15

### <a name="module_elasticache"></a> [elasticache](#module\_elasticache)

Source: terraform-aws-modules/elasticache/aws

Version: 1.11.0

### <a name="module_vpc"></a> [vpc](#module\_vpc)

Source: terraform-aws-modules/vpc/aws

Version: ~> 6.6

## Resources

The following resources are used by this module:

- [aws_security_group.vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_vpc_endpoint.ecr-api-endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) (resource)
- [aws_vpc_endpoint.ecr-dkr-endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) (resource)
- [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
- [aws_iam_policy_document.s3_ecr_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.
