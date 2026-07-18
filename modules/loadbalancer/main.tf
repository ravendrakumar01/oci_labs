terraform {
  required_version = ">= 1.6.3"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

# --- Load Balancer (flexible shape) ---
resource "oci_load_balancer_load_balancer" "this" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  shape          = "flexible"
  subnet_ids     = var.subnet_ids
  is_private     = var.is_private

  shape_details {
    minimum_bandwidth_in_mbps = var.min_mbps
    maximum_bandwidth_in_mbps = var.max_mbps
  }
}

# --- Backend Set (with health check) ---
resource "oci_load_balancer_backend_set" "this" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = "${var.display_name}-bset"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = var.health_check_protocol
    port     = var.backend_port
    url_path = var.health_check_protocol == "HTTP" ? var.health_check_url : null
  }
}

# --- Backends (one per entry; keys are static names) ---
resource "oci_load_balancer_backend" "this" {
  for_each = var.backends

  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.this.name
  ip_address       = each.value.ip
  port             = coalesce(each.value.port, var.backend_port)
}

# --- Listener (front-end) ---
resource "oci_load_balancer_listener" "this" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "${var.display_name}-listener"
  default_backend_set_name = oci_load_balancer_backend_set.this.name
  port                     = var.listener_port
  protocol                 = var.listener_protocol
}
