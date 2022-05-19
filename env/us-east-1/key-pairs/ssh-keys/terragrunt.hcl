include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/keypair/${basename(get_terragrunt_dir())}.hcl"
}

## Variables:
inputs = {}
