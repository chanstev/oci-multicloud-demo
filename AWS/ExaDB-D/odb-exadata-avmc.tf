# Create an Autonomous VM Cluster in the Exadata Infrastructure
resource "aws_odb_cloud_autonomous_vm_cluster" "this" {
  total_container_databases           = 2
  autonomous_data_storage_size_in_tbs = 5
  cloud_exadata_infrastructure_id     = aws_odb_cloud_exadata_infrastructure.this.id
  cpu_core_count_per_node             = 40
  db_servers                          = local.db_servers
  display_name                        = local.name.odb_autonomous_vm_cluster
  maintenance_window {
    preference         = "NO_PREFERENCE"
    lead_time_in_weeks = 1
    days_of_week       = []
    hours_of_day       = []
    months             = []
    weeks_of_month     = []
  }
  memory_per_oracle_compute_unit_in_gbs = 2
  odb_network_id                        = aws_odb_network.this.id
  scan_listener_port_non_tls            = 1521
  scan_listener_port_tls                = 2484
  tags                                  = local.tags
  time_zone                             = "UTC"
  data_storage_size_in_tbs              = 2
  is_mtls_enabled_vm_cluster            = true
  license_model                         = "BRING_YOUR_OWN_LICENSE"
  description                           = "Autonomous VM Cluster"
}
