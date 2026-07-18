variable "compartment_id" {
  type        = string
  description = "Compartment OCID for the databases."
}

variable "databases" {
  description = <<-EOT
    Map of Autonomous Databases (ATP/ADW). KEY = display name.
      - db_name        : DB name (letters/numbers, no spaces, max 14 chars)
      - admin_password : ADMIN password (12-30 chars, upper+lower+number, cannot contain "admin")
                         IMPORTANT: pass via a sensitive variable, do NOT hardcode/commit.
      - db_workload    : "OLTP" (ATP) or "DW" (ADW). default OLTP
      - is_free_tier   : true = Always-Free (1 OCPU, 20GB). default true
      - cpu_core_count : used only when is_free_tier = false. default 1
      - storage_tbs    : used only when is_free_tier = false. default 1
  EOT
  type = map(object({
    db_name        = string
    admin_password = string
    db_workload    = optional(string, "OLTP")
    is_free_tier   = optional(bool, true)
    cpu_core_count = optional(number, 1)
    storage_tbs    = optional(number, 1)
  }))
  default = {}
  # NOTE: not marked `sensitive` because Terraform can't use sensitive values
  # in for_each. The admin_password is still protected by the provider (it is
  # marked sensitive in state/plan output by the oci provider).
}
