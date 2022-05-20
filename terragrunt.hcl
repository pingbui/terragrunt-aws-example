# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl", "global.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl", "account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl", "global.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl", "global.hcl"))

  # Extract the variables we need for easy access
  project_name = try(local.global_vars.locals.project_name, "example")
  account_id   = try(local.account_vars.locals.aws_account_id, "987654321012")
  aws_region   = try(local.region_vars.locals.aws_region, "us-east-1")
  env          = try(local.env_vars.locals.env, "dev")
  state_region = local.global_vars.locals.state_region
}

terraform {
  extra_arguments "-var-file" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      find_in_parent_folders("group.tfvars", "ignore"),
    ]
  }
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    encrypt        = true
    bucket         = format("${local.project_name}-tfstate-%s", try(get_aws_account_id(), local.account_id))
    key            = local.env == "common" ? "${path_relative_to_include()}/terraform.tfstate" : "${replace(path_relative_to_include(), "env/", "${local.env}/")}/terraform.tfstate"
    region         = try(local.state_region, local.aws_region)
    dynamodb_table = "${local.project_name}-terraform-locks"

    skip_metadata_api_check     = true // commented when using with iam_role on ec2
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = var.aws_region
  allowed_account_ids = ["${local.account_id}"]

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true // commented when using with iam_role on ec2
  skip_region_validation      = true
  skip_credentials_validation = true
}

variable "aws_region" {
  description = "AWS region to create infrastructure in"
  type        = string
  default     = "${local.aws_region}"
}
EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.global_vars.locals,
  local.region_vars.locals,
  local.env_vars.locals,
)
