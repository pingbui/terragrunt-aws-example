terraform {
  source = "github.com/pingbui/terraform-aws.git//keypair?ref=0.2.2"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env          = try(local.env_vars.locals.env, "dev")
  env_desc     = try(local.env_vars.locals.env_desc, "example")
  project_name = try(local.global_vars.locals.project_name, "example")
  key_name     = lower("${local.project_name}-${local.env}")

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Name = lower("${local.global_vars.locals.project_name}-${local.env}")
      Env  = local.env_desc
    }
  )
}

inputs = {
  names    = [local.key_name]
  save_dir = get_terragrunt_dir()
  tags     = local.tags
}
