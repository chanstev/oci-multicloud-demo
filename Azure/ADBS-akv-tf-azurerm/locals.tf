locals {
  # Basics
  location = "uksouth"
  tags = {
    owner   = "steven.s.chan@oracle.com"
    purpose = "Demo of ADBS with CMK using AKV"
  }
  zone = "1"

  # Resource Group
  resource_group_name = "rg-scdemo-adbs-${random_string.this.result}"
  resource_group_id   = azurerm_resource_group.this.id

  # Virtual Network
  vnet_name = "vnet-odb-uks"
  vnet_cidr = ["10.0.0.0/16"]
  virtual_network_id   = azurerm_virtual_network.this.id

  odb_subnet_name = "snet-odb-uks"
  odb_subnet_cidr = ["10.0.0.0/24"]
  odb_subnet_id   = azurerm_subnet.odb_subnet.id

  jumpbox_subnet_name = "snet-jumpbox-uks"
  jumpbox_subnet_cidr = ["10.0.1.0/24"]

  akv_subnet_name = "snet-akv-uks"
  akv_subnet_cidr = ["10.0.2.0/24"]

  pdns_inb_subnet_name = "snet-pdns-inb"
  pdns_inb_subnet_cidr = ["10.0.3.0/24"]

  pdns_outb_subnet_name = "snet-pdns-outb"
  pdns_outb_subnet_cidr = ["10.0.4.0/24"]

  adbs_name = "akvdemo"
  sshPublicKey_path = "~/.ssh/ssh-key-2023-12-05.key"

  akv_name = "akv-scdemo-uks01"
  tenant_id = "6798aca3-9d44-4ba7-8a36-39770fe4ab9e"
}

