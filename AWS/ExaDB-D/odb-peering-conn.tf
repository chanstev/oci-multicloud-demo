# Create a Peering Connection between the ODB Network and the VPC
resource "aws_odb_network_peering_connection" "this" {
  display_name    = local.name.odb_peering_connection
  odb_network_id  = aws_odb_network.this.id
  peer_network_id = module.vpc.vpc_attributes.id
  region          = local.location.region
  tags            = local.tags
}