# Create an ODB Network
resource "aws_odb_network" "this" {
  display_name         = local.name.odb_network
  region               = local.location.region
  availability_zone    = local.location.az_name
  availability_zone_id = local.location.az_id
  client_subnet_cidr   = local.odb_network.client_subnet_cidr
  backup_subnet_cidr   = local.odb_network.backup_subnet_cidr
  s3_access            = "DISABLED"
  zero_etl_access      = "DISABLED"
  custom_domain_name   = null
  default_dns_prefix   = null
  s3_policy_document   = null
  tags                 = local.tags
}
