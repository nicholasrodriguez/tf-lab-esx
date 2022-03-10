# terraform-lab
Lab for Terraform Associate Exam

[https://learn.hashicorp.com/collections/terraform/certification-associate-tutorials]

# Notes

## Migrate State From TFC back to Local

```
mv backend.tf backend.tf.old
terraform init -migrate-state
```
## Migrate State From Local back to TFC
Make sure backend.tf is available
```
rm terraform.tfstate
terraform init -migrate-state
terraform plan
```

## Execution Mode
Set Execution Mode on workspace to Local for internal runs i.e. for home lab hosts not on the internet. This just stores the state remotely.

## Check State of Specific Resource
```
terraform state show esxi_guest.vmtest
```

# Notes from Learn terraform





## Troubleshoot Terraform

https://learn.hashicorp.com/tutorials/terraform/troubleshooting-workflow?in=terraform/certification-associate-tutorials

The format command scans the current directory for configuration files and rewrites your Terraform configuration files to the recommended format.
```
terraform fmt
```

Terraform validate after formatting your configuration to check your configuration in the context of the providers' expectations.
```
terraform validate
```
### Logging
```
export TF_LOG_CORE=TRACE
export TF_LOG_PROVIDER=TRACE
export TF_LOG_PATH=logs.txt
```
To generate an example of the core and provider logs, run the following
```
terraform refresh

```
Remove a log stream
```
export TF_LOG_CORE=
```
## Modules

https://learn.hashicorp.com/tutorials/terraform/module-use?in=terraform/certification-associate-tutorials

When using a new module for the first time, you must run either `terraform init` or `terraform get` to install the module.

Modules also have output values, which are defined within the module with the output keyword. You can access them by referring to `module.<MODULE NAME>.<OUTPUT NAME>`.


## Code Organisation

https://learn.hashicorp.com/tutorials/terraform/organize-configuration?in=terraform/modules

* main.tf - configures the resources that make up your infrastructure.
* variables.tf- declares input variables for your dev and prod environment prefixes, and the AWS region to deploy to.
* terraform.tfvars.example- defines your region and environment prefixes.
* outputs.tf- specifies the website endpoints for your dev and prod buckets.
* assets- houses your webapp HTML file.


Can use either directories or Workspaces

### Directories
By creating separate directories for each environment, you can shrink the blast radius of your Terraform operations and ensure you will only modify intended infrastructure. Terraform stores your state files on disk in their corresponding configuration directories. Terraform operates only on the state and configuration in the working directory by default.
Directory-separated environments rely on duplicate Terraform code.

### Workspaces
Workspace-separated environments use the same Terraform code but have different state files, which is useful if you want your environments to stay as similar to each other as possible, for example if you are providing development infrastructure to a team that wants to simulate running in production.

However, you must manage your workspaces in the CLI and be aware of the workspace you are working in to avoid accidentally performing operations on the wrong environment.

 ```terraform workspace list```
