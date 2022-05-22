# aws-terraform
Terragrunt and terraform template for aws projects

## Requirements:
1. [Terraform](https://www.terraform.io/): version ~> v1.2.0
2. [Terragrunt](https://terragrunt.gruntwork.io/): version ~> v0.37.1
3. [Aws-vault](https://github.com/99designs/aws-vault): version ~> [v6.3.1](https://github.com/99designs/aws-vault/releases/tag/v6.3.1)
4. Edit $HOME/[.terraformrc](https://www.terraform.io/docs/commands/cli-config.html):
```
plugin_cache_dir = "$HOME/.terraform.d/plugins"
```

## Alias:
```bash
alias tg='terragrunt'
alias tgh='tg hclfmt'
alias tga='tgh && tg apply'
alias tgp='tgh && tg plan'
```

## Steps to provision:
- aws-vault to get AWS Vars:
```sh
aws-vault exec ${project_name}
```
- Change account id in file account.hcl
- Change config in file terragrunt parent if you EC2 role instead of access key
- Update project spec in global.hcl
- Set environment from ENV before provisoning env's resources (Default is 'dev'):
```
## Test env:
export ENV=test

## Staging env:
export ENV=stage

## Production env:
export ENV=prod
```
- Then run:
```bash
(cd env/us-east-1/<resource-dir> && tg apply)
```
