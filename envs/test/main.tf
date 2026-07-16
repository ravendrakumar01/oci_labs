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

# ------------------------------------------------------------
#  Data sources: auto-lookup Availability Domain + latest image
#  (read-only, no cost)
# ------------------------------------------------------------
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ol9" {
  compartment_id           = module.network.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.E4.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ------------------------------------------------------------
#  Compute instances (TEST)
#  Abhi khaali (koi VM nahi banega). Banana ho to instances = { ... }
#  bharo. TEST mein public + private dono subnet available hain:
#    - public_subnet_id  (internet-facing)
#    - private_subnet_id (NAT ke through outbound)
# ------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"

  compartment_id = module.network.compartment_id

  instances = {}

  # Example:
  # instances = {
  #   "test-app-01" = {
  #     availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  #     shape               = "VM.Standard.E4.Flex"
  #     ocpus               = 1
  #     memory_in_gbs       = 8
  #     image_id            = data.oci_core_images.ol9.images[0].id
  #     subnet_id           = module.network.public_subnet_id   # ya private_subnet_id
  #     assign_public_ip    = true
  #     ssh_public_key      = file("~/.ssh/id_rsa.pub")
  #   }
  # }
}
