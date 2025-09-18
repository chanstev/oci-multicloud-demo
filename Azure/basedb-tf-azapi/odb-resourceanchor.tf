# Create sub-compartment in OCI Multicloud Link compartment
resource "azapi_resource" "resourceanchor" {
  depends_on = [azapi_resource.resource_group]
  type       = "Oracle.Database/resourceAnchors@2025-09-01"
  parent_id  = local.resource_group_id
  name       = local.resourceanchor_name

  body = {
    location = "global"
    tags     = local.tags
  }

  # Workaround before AzAPI's schema is updated 
  schema_validation_enabled = false
}
