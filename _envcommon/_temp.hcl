terraform {
  source = "github.com/terraform-google-modules/module-name.git?ref=v1.0.0"
}

## Dependencies:
dependencies {
  paths = []
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
  name_prefix  = lower("${local.project_name}-${local.env}")
  bname        = basename(get_terragrunt_dir())
  name         = "${local.name_prefix}-${local.bname}"

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Env       = local.env_desc
      Namespace = local.project_name
    }
  )
}

inputs = {
  name = local.name
}
