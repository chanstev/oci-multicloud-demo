resource "azapi_resource" "basedatabase" {
  depends_on = [azapi_resource.networkanchor, azapi_resource.resourceanchor, time_sleep.post_networkanchor]
  type       = "Oracle.Database/dbSystems@2025-09-01"
  parent_id  = local.resource_group_id
  name       = local.bdb_name

  body = {
    location = local.location
    name     = local.bdb_name
    properties = {
      adminPassword                = var.db_admin_password
      computeCount                 = 4
      computeModel                 = "ECPU"
      dataStorageSizeInGbs         = 256
      databaseEdition              = "EnterpriseEditionHighPerformance"
      dbSystemOptions              = { storageManagement = "LVM" }
      dbVersion                    = "19.0.0.0"
      displayName                  = local.bdb_name
      hostname                     = local.bdb_hostname
      licenseModel                 = "LicenseIncluded"
      networkAnchorId              = local.networkanchor_id
      nodeCount                    = 1
      resourceAnchorId             = local.resourceanchor_id
      shape                        = "VM.Standard.x86"
      source                       = "None"
      sshPublicKeys                = [file(local.sshPublicKey_path)]
      timeZone                     = "UTC"
    }
    tags  = local.tags
    zones = [local.zone]
  }

  # Create can take up to 24 hours (only occasionally)
  timeouts {
    create = "24h"
    delete = "8h"
  }

  # Workaround before AzAPI's schema is updated 
  schema_validation_enabled = false
}

# Known issue: "VCN has no network security group with name: DefaultAzureNetworkAnchorNsg"
# Workaround: Wait a few moments for the default NSG to become fully visible before provisioning the Base Database.
resource "time_sleep" "post_networkanchor" {
  depends_on = [azapi_resource.networkanchor]
  create_duration = "1m"
}