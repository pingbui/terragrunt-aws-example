terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.0.0"
}

## Dependencies:
dependencies {
  paths = [
    "${dirname(find_in_parent_folders())}/env/${local.aws_region}/vpc",
  ]
}

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/env/${local.aws_region}/vpc"
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_id  = try(local.global_vars.locals.project_id, "example")
  aws_region  = try(local.region_vars.locals.aws_region, "us-east-1")
  env         = try(local.env_vars.locals.env, "dev")
  env_desc    = try(local.env_vars.locals.env_desc, "example")
  name        = basename(get_terragrunt_dir())
  global_tags = try(local.global_vars.locals.tags, {})
  mnt_ips     = try(local.global_vars.locals.mnt_ips, {})
}

inputs = {
  name                   = lower("${local.global_vars.locals.project_name}-${local.env}-${local.name}")
  description            = "Allow access to ${local.env} ${local.name}"
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = dependency.vpc.outputs.vpc_id

  ## Outbound:
  egress_rules            = ["all-all"]
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]

  ## Inbound:
  ingress_with_self = [
    {
      from_port   = "-1"
      to_port     = "-1"
      protocol    = "-1"
      description = "Itself"
    }
  ]
  ingress_with_ipv6_cidr_blocks = []

  ## Others:
  tags = merge(
    local.global_tags,
    {
      Type = local.name
      Env  = local.env_desc
    }
  )
}
