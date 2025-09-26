# Create an Exadata Infrastructure
resource "aws_odb_cloud_exadata_infrastructure" "this" {
  display_name                     = local.name.odb_exadata_infra
  region                           = local.location.region
  availability_zone                = local.location.az_name
  availability_zone_id             = local.location.az_id
  shape                            = local.exadata_infra_shape
  storage_server_type              = local.storage_server_type
  database_server_type             = local.database_server_type
  compute_count                    = 2
  storage_count                    = 3
  customer_contacts_to_send_to_oci = local.customer_contacts_to_send_to_oci
  tags                             = local.tags
  maintenance_window {
    patching_mode                    = "ROLLING"
    preference                       = "NO_PREFERENCE"
    is_custom_action_timeout_enabled = false
    custom_action_timeout_in_mins    = 15
    days_of_week                     = null
    hours_of_day                     = null
    lead_time_in_weeks               = null
    months                           = null
    weeks_of_month                   = null
  }
}

# Get list of DB Servers in the Exadata Infrastructure
data "aws_odb_db_servers" "this" {
  cloud_exadata_infrastructure_id = aws_odb_cloud_exadata_infrastructure.this.id
}
