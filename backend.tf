# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket                      = "example-tfstate-987654321012"
    dynamodb_table              = "example-terraform-locks"
    encrypt                     = true
    key                         = "./terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
