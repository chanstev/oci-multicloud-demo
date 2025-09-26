locals {
  # AWS provider settings
  profile             = "OCI-Demo"
  shared_config_files = ["~/.aws/config"]

  # Location settings 
  location = {
    region  = "us-east-1"
    az_name = "us-east-1b"
    az_id   = "use1-az6"
  }

  # Resource names
  suffix = "odbdemo"
  name = {
    # Network resources
    vpc                    = "tf-vpc-${local.suffix}"
    odb_network            = "tf-odb-network-${local.suffix}"
    odb_peering_connection = "tf-odb-peering-conn-${local.suffix}"

    # Ofake Exadata resources
    odb_exadata_infra         = "ofake-inf-${local.suffix}"
    odb_vmc_display_name      = "ofake-vmc-${local.suffix}"
    odb_gi_cluster_name       = "ofake-gic-${local.suffix}"
    odb_autonomous_vm_cluster = "ofake-avmc-${local.suffix}"
  }

  # Resource tags
  tags = {
    createdvia = "terraform"
    env        = "demo"
    owner      = "steven"
  }

  # Network settings
  odb_network = {
    backup_subnet_cidr = "10.33.0.0/24"
    client_subnet_cidr = "10.33.1.0/24"
  }

  app_network = {
    vpc_cidr             = "10.30.0.0/16"
    workload_subnet_cidr = "10.30.1.0/24"
  }

  # Exadata Infrastructure
  exadata_infra_shape  = "Exadata.X11M"
  database_server_type = lower(local.exadata_infra_shape) == "exadata.x11m" ? "X11M" : null
  storage_server_type  = lower(local.exadata_infra_shape) == "exadata.x11m" ? "X11M-HC" : null
  customer_contacts_to_send_to_oci = [{
    email = local.tags.owner
  }]

  # Exadata VM Cluster & Autonomous VM Cluster
  db_servers = data.aws_odb_db_servers.this.db_servers[*].id

  ssh_public_keys = [
    file("~/.ssh/demo-ssh-key.pub"),
  ]
}
