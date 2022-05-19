# aws-terraform
Terragrunt and terraform template for aws projects

## Requirements:
1. [Terraform](https://www.terraform.io/): version ~> v1.0.10
2. [Terragrunt](https://terragrunt.gruntwork.io/): version ~> v0.35.5
3. [Aws-vault](https://github.com/99designs/aws-vault): version ~> [v6.3.1](https://github.com/99designs/aws-vault/releases/tag/v6.3.1)
4. Edit $HOME/[.terraformrc](https://www.terraform.io/docs/commands/cli-config.html):
```
plugin_cache_dir = "$HOME/.terraform.d/plugins"
```

## Diagram:
![](OverallDiagram.png "OverallDiagram")

## aws-vault to get AWS ENV:
```sh
aws-vault exec ${project_name}
```

## Note :
- Change account id in file account.hcl
- Change config in file terragrunt parent if you EC2 role instead of access key
- Update project spec in global.hcl
- Then run:
```bash
tg run-all apply
```
