terraform {
  source = "github.com/terraform-google-modules/module-name.git?ref=v1.0.0"
}

## Dependencies:
dependencies {
  paths = []
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  project_id  = try(local.global_vars.locals.project_id, "example")
  region      = try(local.region_vars.locals.region, "us-east1")
  env         = try(local.env_vars.locals.env, "dev")
  name        = basename(get_terragrunt_dir())
}

inputs = {
  project_id = local.project_id
}
