# Create network resources in OCI sub-compartment
resource "azapi_resource" "networkanchor" {
  depends_on = [azapi_resource.resourceanchor]
  type       = "Oracle.Database/networkAnchors@2025-09-01"
  parent_id  = local.resource_group_id
  name       = local.networkanchor_name

  body = {
    location = local.location
    name     = local.networkanchor_name
    properties = {
      cidrBlock                            = local.odb_subnet_cidr
      isOracleDnsForwardingEndpointEnabled = false
      isOracleDnsListeningEndpointEnabled  = false
      isOracleToAzureDnsZoneSyncEnabled    = false
      resourceAnchorId                     = local.resourceanchor_id
      subnetId                             = local.odb_subnet_id
    }
    tags  = local.tags
    zones = [local.zone]
  }

  # Known issue: 'embedded schema validation failed: the argument "type" is invalid. "resource type Oracle.Database/networkAnchors can't be found.'
  # Workaround: Disable the validation until AzAPI's schema is updated 
  schema_validation_enabled = false
}
