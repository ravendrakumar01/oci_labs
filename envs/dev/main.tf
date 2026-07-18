# ============================================================
#  DEV Environment — full stack
#  Compartment + VCN + Subnet + IGW + Route Table +
#  Security List (ingress/egress) + Compute VM +
#  Block Volume (attached) + Object Storage Bucket
# ============================================================

# ------------------------------------------------------------
#  1) NETWORK: compartment, VCN, subnet, IGW, route table, SL
# ------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  tenancy_ocid            = var.tenancy_ocid
  name_prefix             = "DEV"
  compartment_name        = "DEV"
  compartment_description = "Compartment for dev workloads"

  vcn_cidr      = "172.17.0.0/16"
  vcn_dns_label = "devvcn"

  # Public subnet + Internet Gateway (VM ko internet access ke liye)
  public_subnet_cidr      = "172.17.1.0/24"
  enable_internet_gateway = true

  # Security List — inbound (ingress) rules
  # NOTE: source "0.0.0.0/0" = poori duniya. Production mein SSH ko
  #       apne office/home IP tak restrict karna best hai (e.g. "1.2.3.4/32").
  ingress_rules = [
    { protocol = "6", port = 22, source = "0.0.0.0/0", description = "SSH" },
    { protocol = "6", port = 80, source = "0.0.0.0/0", description = "HTTP" },
    { protocol = "1", source = "0.0.0.0/0", description = "ICMP (ping)" },
  ]

  # Security List — outbound (egress) rules (VM se bahar jaane ke liye)
  egress_rules = [
    { protocol = "all", destination = "0.0.0.0/0", description = "Allow all outbound" },
  ]
}

# ------------------------------------------------------------
#  Data sources: Availability Domain + latest Oracle Linux 9 image
#  (read-only, no cost). E2.1.Micro = Always-Free x86 shape.
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
#  2) COMPUTE: one VM in the public subnet
# ------------------------------------------------------------
module "compute" {
  source = "../../modules/compute"

  compartment_id = module.network.compartment_id

  instances = {
    "dev-app-01" = {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      shape               = "VM.Standard.E2.1.Micro"
      image_id            = data.oci_core_images.ol9.images[0].id
      subnet_id           = module.network.public_subnet_id
      assign_public_ip    = true
      # ssh_public_key    = file("~/.ssh/id_rsa.pub")   # SSH login ke liye uncomment karo
    }
  }
}

# ------------------------------------------------------------
#  3) STORAGE: block volume (attached to the VM) + a bucket
# ------------------------------------------------------------
module "storage" {
  source = "../../modules/storage"

  compartment_id = module.network.compartment_id

  block_volumes = {
    "dev-data-01" = {
      availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[0].name
      size_in_gbs           = 50
      attach_to_instance_id = module.compute.instance_ids["dev-app-01"]
    }
  }

  buckets = {
    "dev-app-bucket" = {
      versioning = "Enabled"
    }
  }
}

# ------------------------------------------------------------
#  4) LOAD BALANCER (Always-Free flexible, public)
#     VM ko backend banata hai. Listener 80 -> backend 80.
#     NOTE: VM pe port 80 pe web server hoga tabhi backend
#     "healthy" dikhega; abhi health check fail hoga (normal).
# ------------------------------------------------------------
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  compartment_id = module.network.compartment_id
  display_name   = "DEV-LB"
  subnet_ids     = [module.network.public_subnet_id]
  is_private     = false

  listener_port         = 80
  backend_port          = 80
  backend_ips           = [module.compute.private_ips["dev-app-01"]]
  health_check_protocol = "HTTP"
  health_check_url      = "/"
}

# ------------------------------------------------------------
#  5) IAM (groups + policies)  — abhi empty (nothing created).
#     IAM tenancy-level + sensitive hota hai; enable karne se
#     pehle samajh lena. Example niche commented hai.
# ------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  tenancy_ocid = var.tenancy_ocid

  groups   = {}
  policies = {}

  # Example — jab chahiye ho:
  # groups = {
  #   "dev-admins" = { description = "Dev team admins" }
  # }
  # policies = {
  #   "dev-admins-policy" = {
  #     compartment_id = module.network.compartment_id
  #     description    = "Dev admins manage the DEV compartment"
  #     statements     = ["Allow group dev-admins to manage all-resources in compartment DEV"]
  #   }
  # }
}

# ------------------------------------------------------------
#  6) DATABASE (Autonomous DB / ATP) — abhi empty.
#     Free-tier ATP slow + limited; admin_password secret hona
#     chahiye (TF_VAR_db_admin_password se do, commit mat karo).
# ------------------------------------------------------------
module "database" {
  source = "../../modules/database"

  compartment_id = module.network.compartment_id

  databases = {}

  # Example — Always-Free ATP:
  # databases = {
  #   "DEVATP" = {
  #     db_name        = "DEVATP"
  #     admin_password = var.db_admin_password   # TF_VAR_db_admin_password
  #     db_workload    = "OLTP"
  #     is_free_tier   = true
  #   }
  # }
}
