terraform {
  required_version = ">= 1.6.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

# Generate a fresh SSH keypair for each instance that sets generate_ssh_key = true.
# A new instance => a new keypair. Existing instances keep their key.
resource "tls_private_key" "this" {
  for_each  = { for k, v in var.instances : k => v if v.generate_ssh_key }
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  # Effective public key per instance:
  #   - if generate_ssh_key => Terraform-generated public key
  #   - else                => user-provided ssh_public_key (may be null)
  ssh_keys = {
    for k, v in var.instances : k => (
      v.generate_ssh_key ? tls_private_key.this[k].public_key_openssh : v.ssh_public_key
    )
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

  metadata = local.ssh_keys[each.key] != null ? {
    ssh_authorized_keys = trimspace(local.ssh_keys[each.key])
  } : {}

  # Shape/ocpus/memory changes (resize) are applied in-place or via reboot by OCI.
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}
