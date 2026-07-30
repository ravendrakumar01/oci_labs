output "compartment_id" {
  description = "OCID of the UAT compartment."
  value       = module.network.compartment_id
}

output "vcn_id" {
  value = module.network.vcn_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_subnet_id" {
  value = module.network.private_subnet_id
}

output "instance_public_ips" {
  value = module.compute.public_ips
}

output "instance_private_ips" {
  value = module.compute.private_ips
}

output "instance_private_keys" {
  description = "Terraform-generated SSH private keys per instance (sensitive)."
  value       = module.compute.private_keys
  sensitive   = true
}

output "block_volume_ids" {
  value = module.storage.volume_ids
}

output "bucket_names" {
  value = module.storage.bucket_names
}
