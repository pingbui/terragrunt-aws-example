terraform {
  source = "github.com/pingbui/terraform-modules.git//ssh/ssh-keys?ref=0.3.0"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env          = try(local.env_vars.locals.env, "dev")
  project_name = try(local.global_vars.locals.project_name, "example")
  key_name     = lower("${local.project_name}-${local.env}")
}

inputs = {
  names    = [local.key_name]
  save_dir = get_terragrunt_dir()
}
