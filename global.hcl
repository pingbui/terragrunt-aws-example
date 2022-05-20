locals {
  project_name   = get_env("PROJECT_NAME", "example")
  operation_team = get_env("OPERATION_TEAM", "admin")
  noti_user      = get_env("NOTI_USER", "admin")
  noti_domain    = get_env("NOTI_DOMAIN", "example.com")
  ssh_user       = get_env("SSH_USER", local.project_name)
  main_region    = "us-east-1" // Main Region of this project

  mnt_ips = {
    "${local.operation_team}_ip1" = "1.2.3.4/32",
    "${local.operation_team}_ip2" = "5.6.7.8/32",
  }

  ## For VPCs:
  cidr_newbits = 4
  cidrs = {
    dev  = { "${local.main_region}" = "10.1.0.0/16" }
    prod = { "${local.main_region}" = "10.10.0.0/16" }
  }

  vpc_settings = {
    prod = {
      enable_nat_gateway = true
      single_nat_gateway = false
    }
  }

  ## Domains:
  domain_locals = {
    prod = "${local.project_name}.local"
    dev  = "${local.project_name}.local"
  }

  ##S3 and CloudFront:
  state_region = get_env("STATE_REGION", local.main_region) // Region of tfstate

  cf_settings = {
  }

  ## Backup: database
  snapshot_window    = "17:05-18:05"
  maintenance_window = "sun:18:15-sun:19:15"
  retention_days     = 14

  ## Backup log:
  logs_retention_in_days = 60

  ## Snapshot:
  ebs_retention_days = 14
  ebs_backup_tags    = { BackupSnapshot = "true" }

  ## Global tags:
  tags = {
    Namespace = local.project_name
    ManagedBy = upper(local.operation_team)
  }
}
