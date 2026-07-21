output "instance_ids" {
  description = "Map of instance name => OCID."
  value       = { for k, v in oci_core_instance.this : k => v.id }
}

output "public_ips" {
  description = "Map of instance name => public IP (empty if none)."
  value       = { for k, v in oci_core_instance.this : k => v.public_ip }
}

output "private_ips" {
  description = "Map of instance name => private IP."
  value       = { for k, v in oci_core_instance.this : k => v.private_ip }
}

output "private_keys" {
  description = "Terraform-generated private keys per instance (only VMs with generate_ssh_key=true)."
  value       = { for k, v in tls_private_key.this : k => v.private_key_openssh }
  sensitive   = true
}
