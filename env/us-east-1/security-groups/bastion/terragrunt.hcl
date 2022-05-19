include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/sg/common.hcl"
}

## Variables:
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"), {})
  mnt_ips     = try(local.global_vars.locals.mnt_ips, {})
}

inputs = {
  ingress_with_self = []
  ingress_with_cidr_blocks = [for k, v in local.mnt_ips :
    {
      cidr_blocks = v
      description = "${upper(k)} - SSH"
      rule        = "ssh-tcp"
    }
  ]
}
