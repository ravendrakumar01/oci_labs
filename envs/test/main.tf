# ============================================================
#  TEST Environment
#  Full networking: public + private subnets, IGW, NAT,
#  route tables and a security list (ports 22, 8000, 9000).
# ============================================================

module "network" {
  source = "../../modules/network"

  tenancy_ocid            = var.tenancy_ocid
  name_prefix             = "TEST"
  compartment_name        = "TEST"
  compartment_description = "we will use this compartment for test workload only"

  vcn_cidr      = "172.16.0.0/16"
  vcn_dns_label = "testvcn"

  public_subnet_cidr          = "172.16.1.0/24"
  public_subnet_display_name  = "TEST_PUB_SUBNET"
  public_subnet_dns_label     = "testpubsubnet"
  private_subnet_cidr         = "172.16.2.0/24"
  private_subnet_display_name = "TEST_PRIV_SUBNET"
  private_subnet_dns_label    = "testprivsubnet"

  enable_internet_gateway = true
  enable_nat_gateway      = true
  ingress_tcp_ports       = [22, 8000, 9000]
}
