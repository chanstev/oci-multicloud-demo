# Azure Resource Group
resource "azapi_resource" resource_group {
  type                      = "Microsoft.Resources/resourceGroups@2025-04-01"
  location                  = local.location
  name                      = local.resource_group_name
  schema_validation_enabled = true
}

# Azure Virtual Network (VNet)
resource "azapi_resource" "vnet" {
  depends_on                = [azapi_resource.resource_group]
  location                  = local.location
  name                      = local.vnet_name
  parent_id                 = local.resource_group_id
  schema_validation_enabled = true
  type                      = "Microsoft.Network/virtualNetworks@2024-07-01"

  body = {
    properties = {
      addressSpace = {
        addressPrefixes = [local.vnet_cidr]
      }
    }
  }
}

# Delegated subnet for Oracle Database
resource "azapi_resource" "odb_subnet" {
  depends_on                = [azapi_resource.vnet]
  name                      = local.odb_subnet_name
  parent_id                 = local.vnet_id
  schema_validation_enabled = true
  type                      = "Microsoft.Network/virtualNetworks/subnets@2024-07-01"

  body = {
    properties = {
      addressPrefixes = [local.odb_subnet_cidr]
      delegations = [{
        name = "Oracle.Database/networkAttachments"
        properties = {
          serviceName = "Oracle.Database/networkAttachments"
        }
        type = "Microsoft.Network/virtualNetworks/subnets/delegations"
      }]
    }
  }
}
