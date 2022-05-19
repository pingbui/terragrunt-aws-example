terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v3.14.0"
}

## Dependencies:
dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env         = local.env_vars.locals.env
  env_desc    = local.env_vars.locals.env_desc
  global_tags = try(local.global_vars.locals.tags, {})
  endpoints = concat(
    [
      {
        name = "s3"
      },
      {
        name = "dynamodb"
      }
    ],
    try(local.global_vars.locals.vpc_settings["${local.env}"]["endpoints"], [])
  )
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  endpoints = { for e in local.endpoints :
    e.name => {
      service         = e.name
      route_table_ids = try(e.service_type, "Gateway") == "Gateway" ? concat(dependency.vpc.outputs.private_route_table_ids, dependency.vpc.outputs.public_route_table_ids) : null
      subnet_ids      = try(e.service_type, "Gateway") == "Interface" ? concat(dependency.vpc.outputs.public_subnets, dependency.vpc.outputs.private_subnets, dependency.vpc.outputs.database_subnets) : null
      service_type    = try(e.service_type, "Gateway")
      tags            = { Name = "${e.name}-vpc-endpoint" }
    }
  }

  tags = merge(
    { Env = local.env_desc },
    local.global_tags
  )

}
