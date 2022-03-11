# Terraform lab
Lab for Terraform Associate Exam

[https://learn.hashicorp.com/collections/terraform/certification-associate-tutorials]

# Notes

Aggregated notes from the above site

# Constructs

## Providers, Versions & Locking

Terraform providers manage resources by communicating between Terraform and target APIs. Whenever the target APIs change or add functionality, provider maintainers may update and version the provider.

When multiple users or automation tools run the same Terraform configuration, they should all use the same versions of their required providers. There are two ways for you to manage provider versions in your configuration.

1. Specify provider version constraints in your configuration's terraform block.
2. Use the dependency lock file

If you do not scope provider version appropriately, Terraform will download the latest provider version that fulfills the version constraint. This may lead to unexpected infrastructure changes. By specifying carefully scoped provider versions and using the dependency lock file, you can ensure Terraform is using the correct provider version so your configuration is applied consistently.

When you initialize a Terraform configuration for the first time with Terraform 0.14 or later, Terraform will generate a new .terraform.lock.hcl file in the current working directory. You should include the lock file in your version control repository to ensure that Terraform uses the same provider versions across your team and in ephemeral remote execution environments.

The lock file causes Terraform to always install the same provider version, ensuring that runs across your team or remote sessions will be consistent.

Note: You should never directly modify the lock file.

The -upgrade flag will upgrade all providers to the latest version consistent within the version constraints previously established in your configuration.

You can also use the -upgrade flag to downgrade the provider versions if the version constraints are modified to specify a lower provider version.

``` terraform init -upgrade
```

## Terraform Block

The terraform {} block contains Terraform settings, including the required providers Terraform will use to provision your infrastructure. For each provider, the source attribute defines an optional hostname, a namespace, and the provider type. Terraform installs providers from the Terraform Registry by default. In this example configuration, the aws provider's source is defined as hashicorp/aws, which is shorthand for registry.terraform.io/hashicorp/aws.

## Providers

The provider block configures the specified provider. A provider is a plugin that Terraform uses to create and manage your resources.

Never hard-code credentials or other secrets in your Terraform configuration files. Like other types of code, you may share and manage your Terraform configuration files using source control, so hard-coding secret values can expose them to attackers.

You can use multiple provider blocks in your Terraform configuration to manage resources from different providers. You can even use different providers together. For example, you could pass the IP address of your AWS EC2 instance to a monitoring resource from DataDog.

```
required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
}
```

## Resources

Use resource blocks to define components of your infrastructure. A resource might be a physical or virtual component such as an EC2 instance, or it can be a logical resource such as a Heroku application.

Resource blocks have two strings before the block: the resource type and the resource name. e.g.
```
resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
```
The resource type is aws_instance and the name is app_server. The prefix of the type maps to the name of the provider. In the example configuration, Terraform manages the aws_instance resource with the aws provider. Together, the resource type and resource name form a unique ID for the resource. For example, the ID for your EC2 instance is aws_instance.app_server.

Resource blocks contain arguments which you use to configure the resource. Arguments can include things like machine sizes, disk image names, or VPC IDs. Our providers reference documents the required and optional arguments for each resource. For your EC2 instance, the example configuration sets the AMI ID to an Ubuntu image, and the instance type to t2.micro, which qualifies for AWS' free tier. It also sets a tag to give the instance a name.

# Actions

## Initialize the directory

When you create a new configuration — or check out an existing configuration from version control — you need to initialize the directory with `terraform init`.

Initializing a configuration directory downloads and installs the providers defined in the configuration, which in this case is the aws provider.

## Format and validate the configuration

We recommend using consistent formatting in all of your configuration files. The `terraform fmt` command automatically updates configurations in the current directory for readability and consistency.

Terraform will print out the names of the files it modified, if any.

You can also make sure your configuration is syntactically valid and internally consistent by using the `terraform validate` command.


## Create infrastructure

`terraform apply` Before it applies any changes, Terraform prints out the execution plan which describes the actions Terraform will take in order to change your infrastructure to match the configuration.

The output format is similar to the diff format generated by tools such as Git. The output has a `+` next to `aws_instance.app_server`, meaning that Terraform will create this resource. Beneath that, it shows the attributes that will be set. When the value displayed is `(known after apply)`, it means that the value will not be known until the resource is created. For example, AWS assigns Amazon Resource Names (ARNs) to instances upon creation, so Terraform cannot know the value of the `arn` attribute until you apply the change and the AWS provider returns that value from the AWS API.

Terraform will now pause and wait for your approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here with no changes made to your infrastructure.

In this case the plan is acceptable, so type `yes` at the confirmation prompt to proceed. Executing the plan will take a few minutes since Terraform waits for the EC2 instance to become available.


## Inspect state

When applied Terraform writes data into a file called `terraform.tfstate`. Terraform stores the IDs and properties of the resources it manages in this file, so that it can update or destroy those resources going forward.

The Terraform state file is the only way Terraform can track which resources it manages, and often contains sensitive information, so you must store your state file securely and restrict access to only trusted team members who need to manage your infrastructure. In production, we recommend storing your state remotely with Terraform Cloud or Terraform Enterprise. Terraform also supports several other remote backends you can use to store and manage your state.

Inspect the current state using `terraform show`.

## Manually Managing State

Terraform has a built-in command called `terraform state` for advanced state management. Use the list subcommand to list of the resources in your project's state.
```
terraform state list
aws_instance.app_server
```

## Destroy infrastructure

The `terraform destroy` command terminates resources managed by your Terraform project. This command is the inverse of `terraform apply` in that it terminates all the resources specified in your Terraform state. It does not destroy resources running elsewhere that are not managed by the current Terraform project.

# TFC Store Remote State

Terraform Cloud allows teams to easily version, audit, and collaborate on infrastructure changes. It also securely stores variables, including API tokens and access keys, and provides a safe, stable environment for long-running Terraform processes.

```
terraform {
  cloud {
    organization = "<ORG_NAME>"
    workspaces {
      name = "Example-Workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
```
Login to TFC
```
terraform login

Terraform will request an API token for app.terraform.io using your browser.

If login is successful, Terraform will store the token in plain text in
the following file for use by subsequent commands:
    /Users/<USER>/.terraform.d/credentials.tfrc.json

Do you want to proceed?
  Only 'yes' will be accepted to confirm.

  Enter a value:
```
Confirm with a yes and follow the workflow in the browser window that will automatically open. You will need to paste the generated API key into your Terminal when prompted.

## Set workspace variables

To integrate TFC with AWS set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the "Environment Variables" section, making sure to mark them as "Sensitive".

## Migrate State From TFC back to Local

```
mv backend.tf backend.tf.old
terraform init -migrate-state
```

## Migrate State From Local back to TFC
Make sure backend.tf is available
```
terraform init
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

# Variables

Variable declarations can appear anywhere in your configuration files. However, we recommend putting them into a separate file called `variables.tf` to make it easier for users to understand how the configuration is meant to be customized.

To parameterize an argument with an input variable, you will first define the variable in `variables.tf`, then replace the hardcoded value with a reference to that variable in your configuration.

Variable blocks have three optional arguments.

* Description: A short description to document the purpose of the variable.
* Type: The type of data contained in the variable.
* Default: The default value.

We recommend setting a description and type for all variables, and setting a default value when practical.

If you do not set a default value for a variable, you must assign a value before Terraform can apply the configuration. Terraform does not support unassigned variables. You will see some of the ways to assign values to variables later in this tutorial.

Variable values must be literal values, and cannot use computed values like resource attributes, expressions, or other variables.

You can refer to variables in your configuration with `var.<variable_name>`.

In addition to strings and numbers, Terraform supports several other variable types. A variable with type bool represents true/false values

Terraform also supports collection variable types that contain more than one value. Terraform supports several collection variable types.

* List: A sequence of values of the same type.
* Map: A lookup table, matching keys to values, all of the same type.
* Set: An unordered collection of unique values, all of the same type.

With the following defined
```
variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default     = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}
```
Use Terraform Console
```
terraform console
> var.private_subnet_cidr_blocks
tolist([
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24",
  "10.0.104.0/24",
  "10.0.105.0/24",
  "10.0.106.0/24",
  "10.0.107.0/24",
  "10.0.108.0/24",
])
> var.private_subnet_cidr_blocks[1]
"10.0.102.0/24"
> slice(var.private_subnet_cidr_blocks, 0, 3)
tolist([
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24",
])
```
Leave the console by typing `exit` or pressing `Control-D`.

Terraform will prompt for unassigned variables.

Whenever you execute a plan, destroy, or apply with any variable unassigned, Terraform will prompt you for a value. Entering variable values manually is time consuming and error prone, so Terraform provides several other ways to assign values to variables.

Create a file named `terraform.tfvars` with the following contents.
```
resource_tags = {
  project     = "new-project",
  environment = "test",
  owner       = "me@example.com"
}

ec2_instance_type = "t3.micro"

instance_count = 3
```
Terraform configuration supports string interpolation — inserting the output of an expression into a string. This allows you to use variables, local values, and the output of functions to create strings in your configuration.

Update the names of the security groups to use the project and environment values from the resource_tags map.
```
name        = "web-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
```

### Validate Variables

```
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "my-project",
    environment = "dev"
  }

  validation {
    condition     = length(var.resource_tags["project"]) <= 16 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["project"])) == 0
    error_message = "The project tag must be no more than 16 characters, and only contain letters, numbers, and hyphens."
  }

```


# Output

Output declarations can appear anywhere in your Terraform configuration files. However, we recommend putting them into a separate file called outputs.tf to make it easier for users to understand your configuration and what outputs to expect from it.

e.g.
```
output "vpc_id" {
  description = "ID of project VPC"
  value       = module.vpc.vpc_id
}
```

While the description argument is optional, you should include it in all output declarations to document the intent and content of the output.

You can use the result of any Terraform expression as the value of an output. Use expressions to declare outputs for the load balancer URL and number of web servers provisioned by this configuration by adding the following to outputs.tf.

```
output "lb_url" {
  description = "URL of load balancer"
  value       = "http://${module.elb_http.this_elb_dns_name}/"
}

output "web_server_count" {
  description = "Number of web servers provisioned"
  value       = length(module.ec2_instances.instance_ids)
}
```

The `lb_url `output uses string interpolation to create a URL from the load balancer's domain name. The `web_server_count` output uses the `length() function` to calculate the number of instances attached to the load balancer.

Terraform stores output values in its state file. In order to see these outputs, you need to update the state by applying this new configuration, even though the infrastructure will not change. Respond to the confirmation prompt with a `yes`.


## Query outputs

Now that Terraform has loaded the outputs into your project's state, use the terraform output command to query all of them.

```
terraform output

lb_url = "http://lb-5YI-project-alpha-dev-2144336064.us-east-1.elb.amazonaws.com/"
vpc_id = "vpc-004c2d1ba7394b3d6"
web_server_count = 4
```
Next, query an individual output by name.
```
terraform output lb_url
"http://lb-5YI-project-alpha-dev-2144336064.us-east-1.elb.amazonaws.com/"

```
Starting with version 0.14, Terraform wraps string outputs in quotes by default. You can use the -raw flag when querying a specified output for machine-readable format.
```
terraform output -raw lb_url
http://lb-5YI-project-alpha-dev-2144336064.us-east-1.elb.amazonaws.com/
```
Use the lb_url output value with the -raw flag to cURL the load balancer and verify the response.
```
curl $(terraform output -raw lb_url)
<html><body><div>Hello, world!</div></body></html>
```

## Redact sensitive outputs

You can designate Terraform outputs as sensitive. Terraform will redact the values of sensitive outputs to avoid accidentally printing them out to the console. Use sensitive outputs to share sensitive data from your configuration with other Terraform modules, automation tools, or Terraform Cloud workspaces.

Terraform will redact sensitive outputs when planning, applying, or destroying your configuration, or when you query all of your outputs. Terraform will not redact sensitive outputs in other cases, such as when you query a specific output by name, query all of your outputs in JSON format, or when you use outputs from a child module in your root module.

Add the following sensitive output blocks to your `outputs.tf` file.

```
output "db_username" {
  description = "Database administrator username"
  value       = aws_db_instance.database.username
  sensitive   = true
}
```
Terraform redacts the values of the outputs marked as sensitive in `apply` output

Use `terraform output` to query the database password by name, Terraform will not redact the value when you specify the output by name.
```
terraform output db_password
"notasecurepassword"
```

Generate machine-readable output using ```terraform output -json```. Terraform does not redact sensitive output values with the -json option, because it assumes that an automation tool will use the output.




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

 ```
 terraform workspace list
 terraform workspace new dev
 ```
 Move to a workspace
 ```
 terraform workspace select dev
  ```
 Manage dev environment using dev workspace and vars
  ```
 terraform apply -var-file=dev.tfvars
 ```
 Create a New workspace
 ```
 terraform workspace new prod
 ```
 Manage production environment using prod workspace and vars
 Terraform state is found here
 ```
.
├── README.md
├── assets│
    └── index.html
├── dev.tfvars
├── main.tf
├── outputs.tf
├── prod.tfvars
├── terraform.tfstate.d
│   ├── dev
│   │   └── terraform.tfstate
│   ├── prod
│   │   └── terraform.tfstate
├── terraform.tfvars
└── variables.tf
 ```
 Destroy workspace
 ```
 terraform destroy -var-file=prod.tfvars
 ```
