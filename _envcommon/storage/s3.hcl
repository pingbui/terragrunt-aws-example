terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v2.13.0"
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"), {})
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"), {})
  env         = local.env_vars.locals.env
  env_desc    = local.env_vars.locals.env_desc
  aws_region  = local.region_vars.locals.aws_region
  name        = lower("${basename(get_terragrunt_dir())}-${local.aws_region}")
  name_prefix = lower("${local.global_vars.locals.project_name}-${local.env}")

  tags = merge(
    try(local.global_vars.locals.tags, {}),
    {
      Name = lower("${local.name_prefix}-${local.name}")
      Env  = local.env_desc
    }
  )
}

inputs = {
  bucket = "${local.name_prefix}-${local.name}"
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
