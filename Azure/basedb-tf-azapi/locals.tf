locals {
  # Basics
  location = "uksouth"
  tags = {
    owner   = "owner info here"
    purpose = "Demo of BaseDB with Terraform"
  }
  zone = "1"

  # Resource Group
  resource_group_name = "rg-odb-basedb"
  resource_group_id   = azapi_resource.resource_group.id

  # Virtual Network
  vnet_name = "vnet-odb-uks"
  vnet_cidr = "10.0.0.0/16"
  vnet_id   = azapi_resource.vnet.id

  odb_subnet_name = "snet-odb-uks"
  odb_subnet_cidr = "10.0.0.0/24"
  odb_subnet_id   = azapi_resource.odb_subnet.id

  # ODB Resource Anchor
  resourceanchor_name = "odb-res-anchor"
  resourceanchor_id   = azapi_resource.resourceanchor.id

  # ODB Network Anchor
  networkanchor_name = "odb-net-anchor"
  networkanchor_id   = azapi_resource.networkanchor.id

  # Base DB
  bdb_name          = "odb"
  bdb_hostname      = "odb"
  sshPublicKey_path = "your_sshPublicKey_path"
}

