/*locals {
  env_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  base_vars = read_terragrunt_config(find_in_parent_folders("base.hcl"))
  
  env       = local.env_vars.locals.environment
  base_name = local.base_vars.locals.base_name
}
*/
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/network/vpc"
}

inputs = {
  name                 = "test-vpc"
  enable_dns_support   = false
  enable_dns_hostnames = false
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a","us-east-1b","us-east-1c"]

  tags = {
    "project" = "atomic-company"
  }
}