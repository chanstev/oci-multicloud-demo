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

  # Known issue: 'embedded schema validation failed: the argument "type" is invalid. "resource type Oracle.Database/resourceAnchors can't be found.'
  # Workaround: Disable the validation until AzAPI's schema is updated 
  schema_validation_enabled = false
}
