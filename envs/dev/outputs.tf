output "compartment_id" {
  description = "OCID of the DEV compartment."
  value       = module.network.compartment_id
}

output "vcn_id" {
  description = "OCID of the DEV VCN."
  value       = module.network.vcn_id
}

output "subnet_id" {
  description = "OCID of the DEV public subnet."
  value       = module.network.public_subnet_id
}

output "instance_public_ips" {
  description = "Public IPs of DEV instances."
  value       = module.compute.public_ips
}

output "instance_private_ips" {
  description = "Private IPs of DEV instances."
  value       = module.compute.private_ips
}

output "block_volume_ids" {
  description = "OCIDs of DEV block volumes."
  value       = module.storage.volume_ids
}

output "bucket_names" {
  description = "Names of DEV object storage buckets."
  value       = module.storage.bucket_names
}

output "lb_ip_addresses" {
  description = "Public IP(s) of the DEV load balancer."
  value       = module.loadbalancer.ip_addresses
}

output "instance_private_keys" {
  description = "Terraform-generated SSH private keys per instance (sensitive)."
  value       = module.compute.private_keys
  sensitive   = true
}
