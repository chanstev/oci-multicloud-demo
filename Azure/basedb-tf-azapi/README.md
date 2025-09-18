# Demo: Provisioning Base Database (BaseDB) with Terraform (AzAPI)

This example demonstrates how to provision a Base Database (BaseDB) on Oracle Database@Azure using Terraform with AzAPI provider.

## Prerequisites

1. **Azure Subscription** is [onboarded to Oracle Database@Azure](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/oaaonboard.htm)
2. **Terraform**: is [configured](https://learn.microsoft.com/en-us/azure/developer/terraform/quickstart-configure) and [authenticated to Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure)

## Resources to be provisioned via Terraform (AzAPI)

1. [Prerequisites](./prerequisites.tf)
    - Resource Group
    - Virtual Network (VNet)
    - Delegated subnet for Oracle Database
2. [Resource Anchor](./odb-resourceanchor.tf): Creating sub-compartment in OCI, inside the OCI Multicloud Link compartment
3. [Network Anchor](./odb-networkanchor.tf): Creating network resources in OCI, including VCN, NSG, etc.
4. [Base Database](./odb-basedb.tf)

## Provision Steps

1. Configure the [locals.tf](./locals.tf) with your own value.
2. Initializes the Terraform working directory
    ```
    terraform init
    ```
3. Review the changes that Terraform plans to make
    ```
    terraform plan
    ```
4. Provision the resources
    ```
    terraform apply
    ```

## Clean up
1. Remove all resources managed by the Terraform configuration
    ```
    terraform destroy
    ```