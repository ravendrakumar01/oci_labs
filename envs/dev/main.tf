# ============================================================
#  DEV Environment
#  Only compartment + VCN + subnet for now.
#  Routing / gateways / security will be added later.
# ============================================================

module "network" {
  source = "../../modules/network"

  tenancy_ocid            = var.tenancy_ocid
  name_prefix             = "DEV"
  compartment_name        = "DEV"
  compartment_description = "we will use this compartment for dev workload only"

  vcn_cidr      = "172.17.0.0/16"
  vcn_dns_label = "devvcn"

  public_subnet_cidr         = "172.17.1.0/24"
  public_subnet_display_name = "DEV_SUBNET"
  public_subnet_dns_label    = "devsubnet"

  # Networking to be added later
  enable_internet_gateway = false
  enable_nat_gateway      = false
  ingress_tcp_ports       = []
}
