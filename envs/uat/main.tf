# ============================================================
#  UAT Environment (compartment: UAT)
#  Compartment + VCN + public & private subnet + security list
#  + VM + 50GB block volume (attached) + bucket
# ============================================================

# ------------------------------------------------------------
#  1) NETWORK: compartment, VCN, pub+priv subnet, IGW, NAT, SL
# ------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  tenancy_ocid            = var.tenancy_ocid
  name_prefix             = "UAT"
  compartment_name        = "UAT"
  compartment_description = "Compartment for UAT workloads"

  vcn_cidr      = "172.18.0.0/16"
  vcn_dns_label = "uatvcn"

  # public subnet + Internet Gateway
  public_subnet_cidr      = "172.18.1.0/24"
  enable_internet_gateway = true

  # private subnet + NAT Gateway (private VMs ko outbound internet)
  private_subnet_cidr = "172.18.2.0/24"
  enable_nat_gateway  = true

  # Security List — inbound
  ingress_rules = [
    { protocol = "6", port = 22, source = "0.0.0.0/0", description = "SSH" },
    { protocol = "6", port = 80, source = "0.0.0.0/0", description = "HTTP" },
    { protocol = "1", source = "0.0.0.0/0", description = "ICMP (ping)" },
  ]

  # Security List — outbound
  egress_rules = [
    { protocol = "all", destination = "0.0.0.0/0", description = "Allow all outbound" },
  ]
}

# ------------------------------------------------------------
#  Data sources: AD + latest Oracle Linux 9 (E2.1.Micro)
# ------------------------------------------------------------
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ol9" {
  compartment_id           = module.network.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ------------------------------------------------------------
#  2) COMPUTE: one VM (auto-generated SSH key)
# ------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"

  compartment_id = module.network.compartment_id

  instances = {
    "uat-app-01" = {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      shape               = "VM.Standard.E2.1.Micro"
      image_id            = data.oci_core_images.ol9.images[0].id
      subnet_id           = module.network.public_subnet_id
      assign_public_ip    = true
      generate_ssh_key    = true
    }
  }
}

# ------------------------------------------------------------
#  3) STORAGE: 50GB block volume (attached) + bucket
# ------------------------------------------------------------
module "storage" {
  source = "../../modules/storage"

  compartment_id = module.network.compartment_id
  tenancy_ocid   = var.tenancy_ocid

  block_volumes = {
    "uat-data-01" = {
      availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[0].name
      size_in_gbs           = 70
      attach                = true
      attach_to_instance_id = module.compute.instance_ids["uat-app-01"]
    }
  }

  buckets = {
    "uat-app-bucket" = {
      versioning = "Enabled"
    }
  }
}
