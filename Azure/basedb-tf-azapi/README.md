# Demo: Provisioning Base Database (BaseDB) with Terraform (AzAPI)

This example demonstrates how to provision a Base Database (BaseDB) on Oracle Database@Azure using Terraform with the AzAPI provider.

## Prerequisites

1. **Azure Subscription** Your subscription must be [onboarded to Oracle Database@Azure.](https://docs.oracle.com/en-us/iaas/Content/database-at-azure/oaaonboard.htm)
2. **Terraform**: Ensure Terraform is [installed, configured](https://learn.microsoft.com/en-us/azure/developer/terraform/quickstart-configure), and [authenticated](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure) for use with Azure.

## Resources to be provisioned via Terraform (AzAPI)

1. [Prerequisites](./prerequisites.tf)
    - Resource Group
    - Virtual Network (VNet)
    - Delegated subnet for Oracle Database
2. [Resource Anchor](./odb-resourceanchor.tf): Create a sub-compartment in OCI within the OCI Multicloud Link compartment.
3. [Network Anchor](./odb-networkanchor.tf): Create network resources in OCI, including VCN, NSG, and related components.
4. [Base Database](./odb-basedb.tf)

## Provision Steps

1. Update the [locals.tf](./locals.tf) file with your specific values.
2. Initialize the Terraform working directory:
    ```
    terraform init
    ```
3. Review the changes that Terraform will make:
    ```
    terraform plan
    ```
4. Apply the configuration to provision the resources:
    ```
    terraform apply
    ```

## Clean up
1. Remove all resources managed by this Terraform configuration:
    ```
    terraform destroy
    ```