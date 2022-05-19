terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-key-pair.git?ref=v1.0.1"
}

## Dependencies:
dependencies {
  paths = ["../ssh-keys"]
}

dependency "ssh" {
  config_path = "../ssh-keys"
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
  key_name   = local.key_name
  public_key = try(dependency.ssh.outputs.public_keys[local.key_name], "")
  tags       = local.tags
}
