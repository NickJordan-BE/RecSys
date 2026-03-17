# S3 backend needs to be provisioned via AWS CLI or UI
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.36"
    }
  }

  backend "s3" {
    bucket = "recsys-terraform-state-bucket"
    key = "dev/iam/state/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
    use_lockfile = true
  }

  required_version = ">= 1.14.7"
}
