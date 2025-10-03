resource "random_string" "this" {
  length  = 3
  special = false
}

# Resource Group
resource "azurerm_resource_group" "this" {
  location = local.location
  name     = local.resource_group_name
  tags     = local.tags
}

# Vnet
resource "azurerm_virtual_network" "this" {
  address_space                  = local.vnet_cidr
  location                       = local.location
  name                           = local.vnet_name
  private_endpoint_vnet_policies = "Disabled"
  resource_group_name            = local.resource_group_name
  tags                           = local.tags
}

# ODB subnet
resource "azurerm_subnet" "odb_subnet" {
  name                 = local.odb_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = local.odb_subnet_cidr
  service_endpoints    = ["Microsoft.KeyVault"]

  delegation {
    name = "Oracle.Database/networkAttachments"
    service_delegation {
      name    = "Oracle.Database/networkAttachments"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
