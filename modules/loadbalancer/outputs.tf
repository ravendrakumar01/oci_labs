output "load_balancer_id" {
  description = "OCID of the load balancer."
  value       = oci_load_balancer_load_balancer.this.id
}

output "ip_addresses" {
  description = "Public/private IP address(es) of the load balancer."
  value       = [for ip in oci_load_balancer_load_balancer.this.ip_address_details : ip.ip_address]
}
