variable "compartment_id" {
  type        = string
  description = "Compartment OCID where storage resources will be created."
}

variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID — used to look up the Object Storage namespace (known at plan time)."
}

variable "block_volumes" {
  description = <<-EOT
    Map of block volumes. The map KEY = volume display name.
      - availability_domain   (required) same AD as the instance you attach to
      - size_in_gbs           default 50 (min 50)
      - vpus_per_gb           performance: 0=lower cost, 10=balanced (default), 20+=higher
      - attach_to_instance_id OCID of instance to attach to (null = leave unattached)
  EOT
  type = map(object({
    availability_domain   = string
    size_in_gbs           = optional(number, 50)
    vpus_per_gb           = optional(number, 10)
    attach                = optional(bool, false) # true = attach to instance (static, known at plan)
    attach_to_instance_id = optional(string)      # instance OCID (may be known only after apply)
  }))
  default = {}
}

variable "buckets" {
  description = <<-EOT
    Map of Object Storage buckets. The map KEY = bucket name (unique in tenancy).
      - access_type  "NoPublicAccess" (default) or "ObjectRead" / "ObjectReadWithoutList"
      - versioning   "Disabled" (default) or "Enabled"
      - storage_tier "Standard" (default) or "Archive"
  EOT
  type = map(object({
    access_type  = optional(string, "NoPublicAccess")
    versioning   = optional(string, "Disabled")
    storage_tier = optional(string, "Standard")
  }))
  default = {}
}
