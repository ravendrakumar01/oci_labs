terraform {
  required_version = ">= 1.6.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# --- Compartment ---
resource "oci_identity_compartment" "this" {
  compartment_id = var.tenancy_ocid
  name           = var.compartment_name
  description    = var.compartment_description
  enable_delete  = true
}

# --- VCN ---
resource "oci_core_vcn" "this" {
  compartment_id = oci_identity_compartment.this.id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.name_prefix}_VCN"
  dns_label      = var.vcn_dns_label
}

# --- Internet Gateway (optional) ---
resource "oci_core_internet_gateway" "this" {
  count          = var.enable_internet_gateway ? 1 : 0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}_IG"
  enabled        = true
}

# --- NAT Gateway (optional) ---
resource "oci_core_nat_gateway" "this" {
  count          = var.enable_nat_gateway ? 1 : 0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}_NAT"
}

# --- Public Route Table (only when IGW is enabled) ---
resource "oci_core_route_table" "public" {
  count          = var.enable_internet_gateway ? 1 : 0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}_PUB_RT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this[0].id
  }
}

# --- Private Route Table (only when NAT is enabled) ---
resource "oci_core_route_table" "private" {
  count          = var.enable_nat_gateway ? 1 : 0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}_PRIV_RT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this[0].id
  }
}

# --- Security List (created only when ingress rules are provided) ---
resource "oci_core_security_list" "this" {
  count          = length(var.ingress_rules) > 0 ? 1 : 0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name_prefix}_SL"

  # Outbound rules
  dynamic "egress_security_rules" {
    for_each = var.egress_rules
    content {
      protocol    = egress_security_rules.value.protocol
      destination = egress_security_rules.value.destination
      description = egress_security_rules.value.description

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.protocol == "6" && egress_security_rules.value.port != null ? [1] : []
        content {
          min = egress_security_rules.value.port
          max = egress_security_rules.value.port
        }
      }
      dynamic "udp_options" {
        for_each = egress_security_rules.value.protocol == "17" && egress_security_rules.value.port != null ? [1] : []
        content {
          min = egress_security_rules.value.port
          max = egress_security_rules.value.port
        }
      }
    }
  }

  # Inbound rules
  dynamic "ingress_security_rules" {
    for_each = var.ingress_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      description = ingress_security_rules.value.description

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "6" && ingress_security_rules.value.port != null ? [1] : []
        content {
          min = ingress_security_rules.value.port
          max = ingress_security_rules.value.port
        }
      }
      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "17" && ingress_security_rules.value.port != null ? [1] : []
        content {
          min = ingress_security_rules.value.port
          max = ingress_security_rules.value.port
        }
      }
    }
  }
}

# --- Public / Primary Subnet (optional) ---
resource "oci_core_subnet" "public" {
  count          = var.public_subnet_cidr != null ? 1 : 0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  cidr_block     = var.public_subnet_cidr
  display_name   = coalesce(var.public_subnet_display_name, "${var.name_prefix}_PUB_SUBNET")
  dns_label      = coalesce(var.public_subnet_dns_label, "${lower(var.name_prefix)}pub")

  route_table_id             = var.enable_internet_gateway ? oci_core_route_table.public[0].id : null
  security_list_ids          = length(var.ingress_rules) > 0 ? [oci_core_security_list.this[0].id] : null
  prohibit_public_ip_on_vnic = false
}

# --- Private Subnet (optional) ---
resource "oci_core_subnet" "private" {
  count          = var.private_subnet_cidr != null ? 1 : 0
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  cidr_block     = var.private_subnet_cidr
  display_name   = coalesce(var.private_subnet_display_name, "${var.name_prefix}_PRIV_SUBNET")
  dns_label      = coalesce(var.private_subnet_dns_label, "${lower(var.name_prefix)}priv")

  route_table_id             = var.enable_nat_gateway ? oci_core_route_table.private[0].id : null
  security_list_ids          = length(var.ingress_rules) > 0 ? [oci_core_security_list.this[0].id] : null
  prohibit_public_ip_on_vnic = true
}
