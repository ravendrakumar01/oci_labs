terraform {
  required_version = ">= 1.6.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# --- Groups (tenancy-level) ---
resource "oci_identity_group" "this" {
  for_each = var.groups

  compartment_id = var.tenancy_ocid
  name           = each.key
  description    = each.value.description
}

# --- Policies ---
resource "oci_identity_policy" "this" {
  for_each = var.policies

  compartment_id = each.value.compartment_id
  name           = each.key
  description    = each.value.description
  statements     = each.value.statements
}
