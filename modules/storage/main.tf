terraform {
  required_version = ">= 1.6.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# Object Storage namespace is unique per tenancy; needed to create buckets.
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_id
}

# --- Block Volumes ---
resource "oci_core_volume" "this" {
  for_each = var.block_volumes

  compartment_id      = var.compartment_id
  availability_domain = each.value.availability_domain
  display_name        = each.key
  size_in_gbs         = each.value.size_in_gbs
  vpus_per_gb         = each.value.vpus_per_gb
}

# --- Attach volumes to instances (only those with attach_to_instance_id set) ---
resource "oci_core_volume_attachment" "this" {
  for_each = { for k, v in var.block_volumes : k => v if v.attach }

  attachment_type = "paravirtualized"
  instance_id     = each.value.attach_to_instance_id
  volume_id       = oci_core_volume.this[each.key].id
  display_name    = "${each.key}-attach"
}

# --- Object Storage Buckets ---
resource "oci_objectstorage_bucket" "this" {
  for_each = var.buckets

  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = each.key
  access_type    = each.value.access_type
  storage_tier   = each.value.storage_tier
  versioning     = each.value.versioning
}
