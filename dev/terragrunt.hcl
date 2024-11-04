locals {
  aws_region        = "us-east-1"
  deployment_prefix = "saas-example"
  account_id        = "419638816579"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.deployment_prefix}-terragrunt-states-1234567892014sj2"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.aws_region
  allowed_account_ids = [var.account_id]
  default_tags {
    tags = var.default_tags
  }
}

variable "aws_region" {
  type = string
}

variable "account_id"{
  type = string
}

variable "default_tags" {
  type        = map(string)
}
EOF
}

inputs = {
  aws_region        = local.aws_region
  deployment_prefix = local.deployment_prefix
  account_id        = local.account_id
  default_tags = {
    "DeployedBy"       = "Terragrunt",
    "DeploymentPrefix" = local.deployment_prefix
  }
}