terraform {
  source = "github.com/cloudposse/terraform-aws-cloudtrail.git//.?ref=0.21.0"
}

## Dependencies:
dependencies {
  paths = [
    "${dirname(find_in_parent_folders())}/common/${local.aws_region}/s3/${local.name}"
  ]
}

dependency "s3" {
  config_path = "${dirname(find_in_parent_folders())}/common/${local.aws_region}/s3/${local.name}"
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
  name         = basename(get_terragrunt_dir())

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Name = lower("${local.global_vars.locals.project_name}-${local.env}-${local.name}")
      Env  = local.env_desc
    }
  )
}

inputs = {
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_logging                = true
  s3_bucket_name                = dependency.s3.outputs.s3_bucket_id

  namespace = local.project_name
  stage     = local.env
  name      = local.name
  tags      = local.tags
}
