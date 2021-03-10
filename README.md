![Terraform logo](https://www.terraform.io/assets/images/logo-hashicorp-3f10732f.svg)

# Terraform basic commands

## Basic steps

Steps in a Terraform IaC deployment:

1 - Create the config file with the provider and resources that will be deployed. Ex:

`main.tf`

```
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Block of type "resource"
# Composed by two labels, "azurerm_resource_group" and
# "testrg"
resource "azurerm_resource_group" "testrg" {
  name     = "testingTerraform"
  location = "northeurope"
}
```

2 - Run:
    
    $ terraform init

To download the required provider and create the internal Terraform required files before continue.

3 - Execute:
    
    $ terraform plan

To create the "Action plan" that Terraform will use to reach the desired state (resources) defined on the config files.

4 - Run:
    
    $ terraform apply

This will recheck for us the action plan before proceeed. Here, we should check that this action plan is OK before
proceed with the "yes". Here, we could abort the deployment in a safe way with a "no", because no change will be done
until we confirm.

When we apply the changes, a file called **terraform.tfstate** is created with all the IDs and useful data of the resources
that were created. 

> :warning: Caution! The **terraform.tfstate can contain sensitive information (For example: credentials). Do not publish it in a public way.**

This ables Terraform to modify/delete resources. For example, it's used when we use **terraform destroy** to remove the resources that we created.

The current state could be check using:

    $ terraform show

For a more advanced interaction with the state, we could use the command:
    
    $ terraform state <subcommand>

For example, if we want to check the current resources deployed, we could use:

    $ terraform state list

This will return a list of created resources:

```
azurerm_resource_group.testrg
```

## Modifying created resources

As we've seen, the current state of the resources is stored in the **terraform.tfstate** config file. When Terraform
creates a new execution plan, it check the diffs between the current state and the desired state to create that execution
plan.

**After modifying** the resource itself on the .tf file, we need to create a new action plan with this command:

    $ terraform plan -out=somechanges

This -out argument ensures that the new plan is stored in another file, for applying later using that file on the 
**apply** command. If we add some extra data in the modified resource, we'll see:

'+' > For the newly added changes

'~' > Will inform us which resource will be updated

'-' > Changes that will be removed

If we want to **apply the newly created plan**, we should use:

    $ terraform apply "somechanges"

After aplying the new changes, we could check them with:

    $ terraform show

If we want to remove the created infra, we should use:

    $ terraform destroy

This will **remove** the infraestructure, we'll see the '-' symbol
on the items that will be removed. Something pretty important, is that the resources will be removed by Terraform in a secuential-ordered way, removing in a suitable order with all the dependencies.

## Dependencies in TF resources:

There are two main types of dependencies:

- Implicit: Defined by Terraform and the cloud (or not cloud-like) provider. For example, to create a VM a VNET, Subnet, NIC, etc must be created before deploy the VM itself. That dependencies are implicit and managed by Terraform with the action plan.

    Chechout main.tf for some Implicit vars like azurerm_virtual_machine.vm.resource_group_name

- Explicit: When the meta-argument *depends_on* is used to override
over the execution plan.

## Variables

In Terraform you could add some variables in the definition of the configuration (main.tf), but that variables could be described on external files like the 'variables.tf' file.

To fill some of that variables with extra data, we could place a file called:

- terraform.tfvars

or

- *.auto.tfvars

And Terraform will load that files to auto-fill the vars.

For extra variables, for example the sensitive ones, we could use the -var argument to pass some extra vars, like the
admin password:

terraform apply -var 'admin_username=dadmin'

Variables can be composed (optional) by:

- default: default value
- type: type of variable (map, string, etc)
- description: description of the variable itself.
- validation: rules used to check that variables are composed as expected.
- sensitive: avoids to show the variable on the apply/plan commands.

We could use the output variables to continue with the automation stack, we can define that output variables on the main module and later, access to that values with:

    $ terraform output

And
    
    $ terraform output name_of_variable_used
    $ terraform output -json name_of_variable | jq

# Useful links:

- Terraform Registry: https://registry.terraform.io/

- Config of the Azure provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

- Config az cli from Terraform: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli#configuring-azure-cli-authentication-in-terraform

- Terraform templates: https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples

- Terraform expressions: https://www.terraform.io/docs/language/expressions/index.html 