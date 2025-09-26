# Create a VM Cluster in the Exadata Infrastructure
resource "aws_odb_cloud_vm_cluster" "this" {
  cloud_exadata_infrastructure_id = aws_odb_cloud_exadata_infrastructure.this.id
  cluster_name                    = local.name.odb_gi_cluster_name
  cpu_core_count                  = 16
  data_storage_size_in_tbs        = 2
  db_node_storage_size_in_gbs     = 120
  memory_size_in_gbs              = 60
  db_servers                      = local.db_servers
  display_name                    = local.name.odb_vmc_display_name
  gi_version                      = "23.0.0.0"
  hostname_prefix                 = "vm"
  odb_network_id                  = aws_odb_network.this.id
  ssh_public_keys                 = local.ssh_public_keys
  tags                            = local.tags
  timezone                        = "UTC"
  system_version                  = "25.1.6.0.0.250622"
  is_local_backup_enabled         = false
  license_model                   = "BRING_YOUR_OWN_LICENSE"
  is_sparse_diskgroup_enabled     = false
  data_collection_options {
    is_diagnostics_events_enabled = true
    is_health_monitoring_enabled  = true
    is_incident_logs_enabled      = true
  }

  timeouts {
    create = "24h"
    update = "2h"
    delete = "8h"
  }
}
