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

When you initialize a Terraform configuration for the first time with Terraform 0.14 or later, Terraform will generate a new .terraform.lock.hcl file in the current working directory. You **should include the lock file in your version control repository** to ensure that Terraform uses the same provider versions across your team and in ephemeral remote execution environments.

The lock file causes Terraform to always install the same provider version, ensuring that runs across your team or remote sessions will be consistent.

**Note: You should never directly modify the lock file.**

The `-upgrade` flag will upgrade all providers to the latest version consistent within the version constraints previously established in your configuration.

You can also use the `-upgrade` flag to downgrade the provider versions if the version constraints are modified to specify a lower provider version.

```
terraform init -upgrade
```

Use `terraform get` to include new modules or resources in existing configuration

## Terraform Block

The terraform {} block contains Terraform settings, including the required providers Terraform will use to provision your infrastructure. For each provider, the source attribute defines an optional hostname, a namespace, and the provider type. Terraform installs providers from the Terraform Registry by default. In this example configuration, the aws provider's source is defined as hashicorp/aws, which is shorthand for registry.terraform.io/hashicorp/aws.

## Providers

The provider block configures the specified provider. A provider is a plugin that Terraform uses to create and manage your resources.

**Never hard-code credentials or other secrets in your Terraform configuration files**. Like other types of code, you may share and manage your Terraform configuration files using source control, so hard-coding secret values can expose them to attackers.

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
The resource type is `aws_instance` and the name is `app_server`. The prefix of the type maps to the name of the provider. In the example configuration, Terraform manages the `aws_instance` resource with the aws provider. Together, the resource type and resource name form a unique ID for the resource. For example, the ID for your EC2 instance is `aws_instance.app_server`.

Resource blocks contain arguments which you use to configure the resource. Arguments can include things like machine sizes, disk image names, or VPC IDs. Our providers reference documents the required and optional arguments for each resource. For the EC2 instance above, the example configuration sets the AMI ID to an Ubuntu image, and the instance type to t2.micro, which qualifies for AWS' free tier. It also sets a tag to give the instance a name.

# Actions

## Initialize the directory

When you create a new configuration — or check out an existing configuration from version control — you need to initialize the directory with `terraform init`.

Initializing a configuration directory downloads and installs the providers defined in the configuration.

## Format and validate the configuration

We recommend using consistent formatting in all of your configuration files. The `terraform fmt` command automatically updates configurations in the current directory for readability and consistency.

Terraform will print out the names of the files it modified, if any.

You can also make sure your configuration is syntactically valid and internally consistent by using the `terraform validate` command.


## Create infrastructure

`terraform apply`, Before it applies any changes, Terraform prints out the execution plan which describes the actions Terraform will take in order to change your infrastructure to match the configuration.

The output format is similar to the diff format generated by tools such as Git. The output has a `+` next to `aws_instance.app_server`, meaning that Terraform will create this resource. Beneath that, it shows the attributes that will be set. When the value displayed is `(known after apply)`, it means that the value will not be known until the resource is created. For example, AWS assigns Amazon Resource Names (ARNs) to instances upon creation, so Terraform cannot know the value of the `arn` attribute until you apply the change and the AWS provider returns that value from the AWS API.

Terraform will now pause and wait for your approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here with no changes made to your infrastructure.

In this case the plan is acceptable, so type `yes` at the confirmation prompt to proceed. Executing the plan will take a few minutes since Terraform waits for the EC2 instance to become available.


## Inspect state

When applied Terraform writes data into a file called `terraform.tfstate`. Terraform stores the IDs and properties of the resources it manages in this file, so that it can update or destroy those resources going forward.

The Terraform state file is the only way Terraform can track which resources it manages, and often contains sensitive information, so **you must store your state file securely and restrict access to only trusted team members who need to manage your infrastructure**. In production, we recommend storing your state remotely with Terraform Cloud or Terraform Enterprise. Terraform also supports several other remote backends you can use to store and manage your state.

Inspect the current state using `terraform show`.

## Manually Managing State

Terraform has a built-in command called `terraform state` for advanced state management. Use the list subcommand to list of the resources in your project's state.
```
terraform state list
aws_instance.app_server
```

## Destroy infrastructure

The `terraform destroy` command terminates resources managed by your Terraform project. This command is the inverse of `terraform apply` in that it terminates all the resources specified in your Terraform state. It does not destroy resources running elsewhere that are not managed by the current Terraform project.

# Terraform Cloud - Store Remote State

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

Variable declarations can appear anywhere in your configuration files. However, **we recommend putting them into a separate file called** `variables.tf` to make it easier for users to understand how the configuration is meant to be customized.

To parameterize an argument with an input variable, you will first define the variable in `variables.tf`, then replace the hardcoded value with a reference to that variable in your configuration.

Variable blocks have three optional arguments.

* Description: A short description to document the purpose of the variable.
* Type: The type of data contained in the variable.
* Default: The default value.

We recommend setting a description and type for all variables, and setting a default value when practical.

If you do not set a default value for a variable, **you must assign a value before Terraform can apply the configuration**. Terraform does not support unassigned variables. You will see some of the ways to assign values to variables later in this tutorial.

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
Use Terraform Console to query Variables
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

Whenever you execute a `plan`, `destroy`, or `apply` with any variable unassigned, Terraform will prompt you for a value. Entering variable values manually is time consuming and error prone, so Terraform provides several other ways to assign values to variables.

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

Output declarations can appear anywhere in your Terraform configuration files. However, we **recommend putting them into a separate file called** `outputs.tf` to make it easier for users to understand your configuration and what outputs to expect from it.

e.g.
```
output "vpc_id" {
  description = "ID of project VPC"
  value       = module.vpc.vpc_id
}
```

While the description argument is optional, you should include it in all output declarations to document the intent and content of the output.

You can use the result of any Terraform expression as the value of an output. Use expressions to declare outputs for the load balancer URL and number of web servers provisioned by this configuration by adding the following to `outputs.tf`.

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

The `lb_url` output uses string interpolation to create a URL from the load balancer's domain name. The `web_server_count` output uses the `length() function` to calculate the number of instances attached to the load balancer.

Terraform stores output values in its state file. In order to see these outputs, you need to update the state by applying this new configuration, even though the infrastructure will not change. Respond to the confirmation prompt with a `yes`.


## Query outputs

Now that Terraform has loaded the outputs into your project's state, use the `terraform output` command to query all of them.

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
Starting with version 0.14, Terraform wraps string outputs in quotes by default. You can use the `-raw` flag when querying a specified output for machine-readable format.
```
terraform output -raw lb_url
http://lb-5YI-project-alpha-dev-2144336064.us-east-1.elb.amazonaws.com/
```
Use the lb_url output value with the `-raw` flag to CURL the load balancer and verify the response.
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


# Data Sources

Cloud infrastructure, applications, and services emit data, which Terraform can query and act on using data sources. Terraform uses data sources to fetch information from cloud provider APIs, such as disk image IDs, or information about the rest of your infrastructure through the outputs of other Terraform configurations.

Data sources allow you to load data from APIs or other Terraform workspaces. You can use this data to make your project's configuration more flexible, and to connect workspaces that manage different parts of your infrastructure. You can also use data sources to connect and share data between workspaces in Terraform Cloud and Terraform Enterprise.

Use the aws_availability_zones data source to load the available AZs for the current region. Add the following to `main.tf`.

```
data "aws_availability_zones" "available" {
  state = "available"
}
```

The `aws_availability_zones` data source is part of the AWS provider, and its documentation is under its provider in the Terraform registry. Like resources, data source blocks support arguments to specify how they behave. In this case, the state argument limits the availability zones to only those that are currently available.

You can reference data source attributes with the pattern `data.<NAME>.<ATTRIBUTE>`. Update the VPC configuration to use this data source to set the list of availability zones.

```
azs             = data.aws_availability_zones.available.names
```

Set the VPC workspace output the region, which the application workspace requires as an input. Add a data source to main.tf to access region information.

```data "aws_region" "current" { }
```

Add an output for the region to `outputs.tf`.
```
output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}
```

## Source Data From Remote state
This remote state block uses the local backend to load state data from the path in the config section. Terraform remote state also supports a remote backend type for use with remote systems, such as Terraform Cloud, Consul, or other systems.

```
data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../learn-terraform-data-sources-vpc/terraform.tfstate"
  }
}
```

Replace the hard-coded region configuration in main.tf with the region output from the VPC workspace.
```provider "aws" {
    region = data.terraform_remote_state.vpc.outputs.aws_region
 }
```

Configure the load balancer security group and subnet arguments with the corresponding outputs from your VPC workspace.
```
module "elb_http" {
   ## ...

  security_groups = data.terraform_remote_state.vpc.outputs.lb_security_group_ids
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnet_ids
   ## ...
 }
```
Terraform remote state can only load "root-level" output values from the source workspace, it cannot directly access values from resources or modules in the source workspace. To retrieve those values, you must add a corresponding output to the source workspace.

# Resource Dependencies

Terraform infers dependencies between resources based on the configuration given, so that resources are created and destroyed in the correct order. Occasionally, however, Terraform cannot infer dependencies between different parts of your infrastructure, and you will need to create an explicit dependency with the `depends_on` argument.

Terraform automatically infers when one resource depends on another by studying the resource attributes used in interpolation expressions.

Terraform uses this dependency information to determine the correct order in which to create the different resources. To do so, it creates a dependency graph of all of the resources defined by the configuration.

Implicit dependencies are the primary way that Terraform understands the relationships between your resources. Sometimes there are dependencies between resources that are not visible to Terraform, however. The depends_on argument is accepted by any resource or module block and accepts a list of resources to create explicit dependencies for.

```
resource "aws_s3_bucket" "example" {
  acl    = "private"
}

resource "aws_instance" "example_c" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  depends_on = [aws_s3_bucket.example]
}

module "example_sqs_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "2.1.0"

  depends_on = [aws_s3_bucket.example, aws_instance.example_c]
}
```

# Functions

The Terraform configuration language allows you to write declarative expressions to create infrastructure. While the configuration language is not a programming language, you can use several built-in functions to perform operations dynamically and effectively.

```
variable "aws_amis" {
  type = map
  default = {
    "us-east-1" = "ami-0739f8cdb239fe9ae"
    "us-west-2" = "ami-008b09448b998a562"
    "us-east-2" = "ami-0ebc8f6f580a04647"
  }
}
```
This map variable declares an available AMI for each of the three regions where you could deploy your EC2 instance.

```
resource "aws_instance" "web" {
  ami                         = lookup(var.aws_amis, var.aws_region)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_8080.id]
  associate_public_ip_address = true
  user_data                   = templatefile("user_data.tftpl", { department = var.user_department, name = var.user_name })
}
```
The `lookup` function in the example above uses the region you choose as a key. The region key, mapped to a specific AMI ID, assigns that AMI to the instance. Set the output as follows
```
output "ami_value" {
  value = lookup(var.aws_amis, var.aws_region)
}
```

```
resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = file("ssh_key.pub")
}
```
In the example above the `file `function is being used. The file function reads the contents of a file in the provided path and renders it as plaintext in your configuration file. This function does not accept interpolated values in the text and should only be used when a file already on disk is necessary for the configuration.

# Manage Resources in Terraform State

Terraform stores information about your infrastructure in a state file. This state file keeps track of resources created by your configuration and maps them to real-world resources.

Terraform compares your configuration with the state file and your existing infrastructure to create plans and make changes to your infrastructure. When you run terraform apply or terraform destroy against your initialized configuration, Terraform writes metadata about your configuration to the state file and updates your infrastructure resources accordingly.

You should not manually change information in your state file in a real-world situation to avoid unnecessary drift between your Terraform configuration, state, and infrastructure. Any change in state could result in your infrastructure being destroyed and recreated at your next `terraform apply`

The resources section of the state file contains the schema for any resources you create in Terraform

## Examine State with CLI

Run `terraform show` to get a human-friendly output of the resources contained in your state.

Run `terraform state list` to get the list of resource names and local identifiers in your state file. This command is useful for more complex configurations where you need to find a specific resource without parsing state with `terraform show`

```
terraform state list
data.aws_ami.ubuntu
aws_instance.example
aws_security_group.sg_8080
```

## Replace a resource with CLI

Terraform usually only updates your infrastructure if it does not match your configuration. You can use the `-replace` flag for `terraform plan` and `terraform apply` operations to safely recreate resources in your environment even if you have not edited the configuration, which can be useful in cases of system malfunction. Replacing a resource is also useful in cases where a user manually changes a setting on a resource or when you need to update a provisioning script. This allows you to rebuild specific resources and avoid a full `terraform destroy` operation on your configuration. The `-replace` flag allows you to target specific resources and avoid destroying all the resources in your workspace just to fix one of them.

In older versions of Terraform, you may have used the `terraform taint` command to achieve a similar outcome. That command has now been deprecated in favor of the `-replace` flag, which allows for a simpler, less error-prone workflow.

e.g.

```
terraform plan -replace="aws_instance.example"
```
When you apply this change, Terraform will destroy your running instance and create a new one.


## Move a resource to a different state file

Some of the Terraform state subcommands are useful in very specific situations. HashiCorp recommends only performing these advanced operations as the last resort.

The terraform state mv command moves resources from one state file to another. You can also rename resources with mv. The move command will update the resource in state, but not in your configuration file. Moving resources is useful when you want to combine modules or resources from other states, but do not want to destroy and recreate the infrastructure.

Move a new EC2 instance resource `aws_instance.example_new`, to the another configuration file in the directory above your current location, as specified with the `-state-out` flag. Set the destination name to the same name, since in this case there is no resource with the same name in the target state file.

```
terraform state mv -state-out=../terraform.tfstate aws_instance.example_new aws_instance.example_new
```

Resource names must be unique to the intended state file. The t`erraform state mv` command can also rename resources to make them unique.


## Remove a resource from state

The `terraform state rm` subcommand removes specific resources from your state file. This does not remove the resource from your configuration or destroy the infrastructure itself.

```
terraform state rm aws_security_group.sg_8080
Removed aws_security_group.sg_8080
Successfully removed 1 resource instance(s).
```
Confirm the change by reviewing the state with `terraform state list`.
```
$ terraform state list
data.aws_ami.ubuntu
aws_instance.example
```
The removed security_group resource does not exist in the state, but the resource still exists in your AWS account.

Run `terraform import` to bring this security group back into your state file. Removing the security group from state did not remove the output value with its ID, so you can use it for the import.

```
terraform import aws_security_group.sg_8080 $(terraform output -raw security_group)
```

## Refresh modified infrastructure

The `terraform refresh` command updates the state file when physical resources change outside of the Terraform workflow.

Your outputs still exist because Terraform stores them separately from your resources.

The `terraform refresh` command does not update your configuration file. Run `terraform plan` to review the proposed infrastructure updates.

Terraform automatically performs a `refresh` during the `plan`, `apply`, and `destroy` operations. All of these commands will reconcile state by default, and have the potential to modify your state file.

# Import Terraform Configuration

You may need to manage infrastructure that wasn't created by Terraform. Terraform import solves this problem by loading supported resources into your Terraform workspace's state. The import command doesn't automatically generate the configuration to manage the infrastructure, though. Because of this, importing existing infrastructure into Terraform is a multi-step process.

Bringing existing infrastructure under Terraform's control involves five main steps:

1. Identify the existing infrastructure to be imported.
2. Import infrastructure into your Terraform state.
3. Write Terraform configuration that matches that infrastructure.
4. Review the Terraform plan to ensure the configuration matches the expected state and infrastructure.
5. Apply the configuration to update your Terraform state.

Next, define an empty `docker_container` resource in your `docker.tf` file, which represents a Docker container with the Terraform resource ID `docker_container.web`.
```
resource "docker_container" "web" {}
```
Now run `terraform import` to attach the existing Docker container to the `docker_container.web` resource you just created. Terraform import requires this Terraform resource ID and the full Docker container ID. In the following example, the command `docker inspect --format="{{.ID}}" hashicorp-learn` returns the full SHA256 container ID.
```
terraform import docker_container.web $(docker inspect --format="{{.ID}}" hashicorp-learn)
```

Now verify that the container has been imported into your Terraform state by running `terraform show`
```
terraform show
# docker_container.web:
resource "docker_container" "web" {
    command           = [
      "nginx",
      "-g",
      "daemon off;",
    ]
```

# Manage Resource Drift

The Terraform state file is a record of all resources Terraform manages. You should not make manual changes to resources controlled by Terraform, because the state file will be out of sync, or "drift," from the real infrastructure. If your state and configuration do not match your infrastructure, Terraform will attempt to reconcile your infrastructure, which may unintentionally destroy or recreate resources.

## Run a refresh-only plan

By default, Terraform compares your state file to real infrastructure whenever you invoke `terraform plan` or `terraform apply`. The refresh updates your state file in-memory to reflect the actual configuration of your infrastructure. This ensures that Terraform determines the correct changes to make to your resources.

If you suspect that your infrastructure configuration changed outside of the Terraform workflow, you can use a `-refresh-only` flag to inspect what the changes to your state file would be. This is safer than the refresh subcommand, which automatically overwrites your state file without displaying the updates.

Tip: The `-refresh-only` flag was introduced in Terraform 0.15.4, and is preferred over the `terraform refresh` subcommand.

Run `terraform plan -refresh-only` to determine the drift between your current state file and actual configuration.
```
terraform import aws_security_group.sg_web $SG_ID
```

# Use Refresh-Only Mode to Sync Terraform State

Terraform relies on the contents of your workspace's state file to generate an execution plan to make changes to your resources. To ensure the accuracy of the proposed changes, your state file must be up to date.

In Terraform, refreshing your state file updates Terraform's knowledge of your infrastructure, as represented in your state file, with the actual state of your infrastructure. Terraform `plan` and `apply` operations run an implicit in-memory refresh as part of their functionality, reconciling any drift from your state file before suggesting infrastructure changes. You can also update your state file without making modifications to your infrastructure using the `-refresh-only` flag for `plan` and `apply` operations.

In previous versions of Terraform, the only way to refresh your state file was by using the terraform refresh subcommand. However, this was less safe than the -refresh-only plan and apply mode since it would automatically overwrite your state file without giving you the option to review the modifications first. In this case, that would mean automatically dropping all of your resources from your state file.

The `-refresh-only` mode for `terraform plan` and `terraform apply` operations makes it safer to check Terraform state against real infrastructure by letting you review proposed changes to the state file. It lets you avoid mistakenly removing an existing resource from state and gives you a chance to correct your configuration.

A refresh-only `apply` operation also updates outputs, if necessary. If you have any other workspaces that use the `terraform_remote_state` data source to access the outputs of the current workspace, the `-refresh-only` mode allows you to anticipate the downstream effects.

In order to propose accurate changes to your infrastructure, Terraform first attempts to reconcile the resources tracked in your state file with your actual infrastructure. Terraform `plan` and `apply` operations first run an in-memory refresh to determine which changes to propose to your infrastructure. Once you confirm a `terraform apply`, Terraform will update your infrastructure and state file.

Though Terraform will continue to support the `refresh` subcommand in future versions, it is deprecated, and we encourage you to use the `-refresh-only` flag instead. This allows you to review any updates to your state file. Unlike the `refresh` subcommand, `-refresh-only mode` is supported in workspaces using Terraform Cloud as a remote backend, allowing your team to collaboratively review any modifications.

####
# Troubleshoot Terraform

The format command scans the current directory for configuration files and rewrites your Terraform configuration files to the recommended format.
```
terraform fmt
```

Terraform validate after formatting your configuration to check your configuration in the context of the providers' expectations.
```
terraform validate
```
## Logging
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
# Modules

https://learn.hashicorp.com/tutorials/terraform/module-use?in=terraform/certification-associate-tutorials

When using a new module for the first time, you must run either `terraform init` or `terraform get` to install the module.

Modules also have output values, which are defined within the module with the output keyword. You can access them by referring to `module.<MODULE NAME>.<OUTPUT NAME>`.


# Code Organisation

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
