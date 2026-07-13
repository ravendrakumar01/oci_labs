# ============================================================
#  PRODUCTION Environment
#  Only compartment + VCN + subnet for now.
#  Routing / gateways / security will be added later.
# ============================================================

module "network" {
  source = "../../modules/network"

  tenancy_ocid            = var.tenancy_ocid
  name_prefix             = "PROD"
  compartment_name        = "PRODUCTION"
  compartment_description = "we will use this compartment for production workload only"

  vcn_cidr      = "172.15.0.0/16"
  vcn_dns_label = "prodvcn"

  public_subnet_cidr         = "172.15.1.0/24"
  public_subnet_display_name = "PROD_SUBNET"
  public_subnet_dns_label    = "prodsubnet"

  # Networking to be added later
  enable_internet_gateway = true
  enable_nat_gateway      = true
  ingress_tcp_ports       = [22]
}
