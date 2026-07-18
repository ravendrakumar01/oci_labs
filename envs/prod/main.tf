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
  shape                    = "VM.Standard.E2.1.Micro" # Always-Free x86 micro (separate capacity pool)
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ------------------------------------------------------------
#  Compute instances (PROD)
#  Abhi khaali (koi VM nahi banega). Banana ho to niche wale
#  example ko instances = { ... } mein daalo aur push karo.
#  PROD apply pe GitHub approval maanga jayega.
# ------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"

  compartment_id = module.network.compartment_id

  instances = {
    "prod-app-01" = {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      shape               = "VM.Standard.E2.1.Micro" # fixed 1 OCPU / 1 GB (ocpus/memory below ignored)
      image_id            = data.oci_core_images.ol9.images[0].id
      subnet_id           = module.network.public_subnet_id
      assign_public_ip    = true
      # ssh_public_key    = file("~/.ssh/id_rsa.pub")   # SSH access ke liye uncomment karo
    }
  }
}
