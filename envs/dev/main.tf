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
  ingress_tcp_ports       = [22, 4000]
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
#  Compute instances
#  Map ki har KEY = instance ka display name.
#  Instance hatana ho to us entry ko delete kar do.
#  Koi instance na banana ho to: instances = {}
# ------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"

  compartment_id = module.network.compartment_id

  instances = {
    "dev-app-01" = {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      shape               = "VM.Standard.E4.Flex"
      ocpus               = 1
      memory_in_gbs       = 8
      image_id            = data.oci_core_images.ol9.images[0].id
      subnet_id           = module.network.public_subnet_id
      assign_public_ip    = true
      # ssh_public_key    = file("~/.ssh/id_rsa.pub")   # SSH access ke liye uncomment karo
    }
  }
}
