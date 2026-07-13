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
  enable_internet_gateway = true
  enable_nat_gateway      = true
  ingress_tcp_ports       = [22,4000]
}

# envs/dev/main.tf  (module block ke niche)

resource "oci_core_instance" "app" {
  compartment_id      = module.network.compartment_id
  availability_domain = "xxxx:AP-MUMBAI-1-AD-1"   # apne AD ka naam
  shape               = "VM.Standard.E4.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 8
  }

  create_vnic_details {
    subnet_id = module.network.public_subnet_id
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1...."   # image OCID
  }
}
