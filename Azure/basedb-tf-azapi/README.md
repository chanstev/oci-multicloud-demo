# Demo: Provisioning Base Database (BaseDB) with Terraform (AzAPI)

This example demonstrates how to provision a Base Database (BaseDB) on Oracle Database@Azure using Terraform with AzAPI provider.

## Resources to be provisioned

1. [Prerequisites](./prerequisites.tf)
    - Resource Group
    - Virtual Network (VNet)
    - Delegated subnet for Oracle Database
2. [Resource Anchor](./odb-resourceanchor.tf): Creating sub-compartment in OCI, inside the OCI Multicloud Link compartment
3. [Network Anchor](./odb-networkanchor.tf): Creating network resources in OCI, including VCN, NSG, etc.
4. [Base Database](./odb-basedb.tf)