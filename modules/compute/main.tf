terraform {
  required_version = ">= 1.6.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

resource "oci_core_instance" "this" {
  for_each = var.instances

  compartment_id      = var.compartment_id
  availability_domain = each.value.availability_domain
  display_name        = each.key
  shape               = each.value.shape
  freeform_tags       = each.value.freeform_tags

  # shape_config is only valid for Flex shapes
  dynamic "shape_config" {
    for_each = can(regex("Flex", each.value.shape)) ? [1] : []
    content {
      ocpus         = each.value.ocpus
      memory_in_gbs = each.value.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = each.value.subnet_id
    assign_public_ip = each.value.assign_public_ip
    display_name     = "${each.key}-vnic"
    hostname_label   = replace(lower(each.key), "/[^a-z0-9]/", "")
  }

  source_details {
    source_type             = "image"
    source_id               = each.value.image_id
    boot_volume_size_in_gbs = each.value.boot_volume_size_gbs
  }

  metadata = each.value.ssh_public_key != null ? {
    ssh_authorized_keys = each.value.ssh_public_key
  } : {}

  # Shape/ocpus/memory changes (resize) are applied in-place or via reboot by OCI.
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}
