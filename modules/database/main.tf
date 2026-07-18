terraform {
  required_version = ">= 1.6.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# --- Autonomous Database (ATP / ADW) ---
resource "oci_database_autonomous_database" "this" {
  for_each = var.databases

  compartment_id = var.compartment_id
  display_name   = each.key
  db_name        = each.value.db_name
  admin_password = each.value.admin_password
  db_workload    = each.value.db_workload
  is_free_tier   = each.value.is_free_tier

  # Free tier is fixed at 1 OCPU / 1 TB; paid uses the given values.
  cpu_core_count           = each.value.is_free_tier ? 1 : each.value.cpu_core_count
  data_storage_size_in_tbs = each.value.is_free_tier ? 1 : each.value.storage_tbs
}
