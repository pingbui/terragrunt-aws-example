terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc.git//.?ref=${local.version}"
}

## Dependencies:
dependencies {
  paths = ["${dirname(find_in_parent_folders())}/common/${local.aws_region}/aws-data"]
}

dependency "aws-data" {
  config_path = "${dirname(find_in_parent_folders())}/common/${local.aws_region}/aws-data"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  aws_region   = try(local.region_vars.locals.aws_region, "us-east-1")
  env          = try(local.env_vars.locals.env, "dev")
  env_desc     = try(local.env_vars.locals.env_desc, "example")
  project_name = try(local.global_vars.locals.project_name, "example")
  vpc_settings = try(local.global_vars.locals.vpc_settings[local.env], {})
  version      = try(local.vpc_settings["version"], local.global_vars.locals.vpc_settings["version"], "v4.0.1")

  name         = "${local.project_name}-${local.env}"
  cidr         = try(local.vpc_settings.cidr, "10.200.0.0/20")
  cidr_newbits = try(local.vpc_settings.cidr_newbits, "4")

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Env = local.env_desc
    }
  )
}

inputs = {
  name = upper(local.name)
  cidr = local.cidr
  azs  = [for v in dependency.aws-data.outputs.available_aws_availability_zones_names : v]

  public_subnets = [
    "${cidrsubnet(local.cidr, local.cidr_newbits, 0)}",
    "${cidrsubnet(local.cidr, local.cidr_newbits, 1)}",
  ]
  private_subnets = [
    "${cidrsubnet(local.cidr, local.cidr_newbits, 2)}",
    "${cidrsubnet(local.cidr, local.cidr_newbits, 3)}",
  ]
  database_subnets = [
    "${cidrsubnet(local.cidr, local.cidr_newbits, 4)}",
    "${cidrsubnet(local.cidr, local.cidr_newbits, 5)}",
  ]

  enable_nat_gateway           = try(local.vpc_settings["enable_nat_gateway"], false)
  single_nat_gateway           = try(local.vpc_settings["single_nat_gateway"], true)
  enable_dns_support           = try(local.vpc_settings["enable_dns_support"], true)
  enable_dns_hostnames         = try(local.vpc_settings["enable_dns_hostnames"], true)
  enable_vpn_gateway           = try(local.vpc_settings["enable_vpn_gateway"], false)
  map_public_ip_on_launch      = try(local.vpc_settings["map_public_ip_on_launch"], false)
  create_database_subnet_group = try(local.vpc_settings["create_database_subnet_group"], false)
  enable_dhcp_options          = try(local.vpc_settings["enable_dhcp_options"], true)
  dhcp_options_domain_name     = try(local.global_vars.locals.domain_locals[local.env], "")
  tags                         = local.tags

}
