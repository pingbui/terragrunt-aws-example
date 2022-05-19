locals {
  env      = get_env("ENV", "dev") # basename(get_terragrunt_dir())
  env_desc = local.env == "prod" ? "Production" : "${local.env == "stage" ? "Staging" : "${local.env == "dev" ? "Development" : "Test"}"}"
}
