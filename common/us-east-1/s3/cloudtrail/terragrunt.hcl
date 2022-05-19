include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/storage/s3.hcl"
}

## Variables:
locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  aws_region   = try(local.region_vars.locals.aws_region, "us-east-1")
  env          = try(local.env_vars.locals.env, "dev")
  project_name = try(local.global_vars.locals.project_name, "example")
  bucket_name  = lower("${local.project_name}-${local.env}-${basename(get_terragrunt_dir())}-${local.aws_region}")
}

inputs = {
  attach_policy = true
  policy        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${local.bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {"Service": "cloudtrail.amazonaws.com"},
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.bucket_name}/AWSLogs/${local.account_vars.locals.aws_account_id}/*",
            "Condition": {"StringEquals": {"s3:x-amz-acl": "bucket-owner-full-control"}}
        }
    ]
}
EOF
}
