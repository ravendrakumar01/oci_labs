output "compartment_id" {
  description = "OCID of the created compartment."
  value       = oci_identity_compartment.this.id
}

output "vcn_id" {
  description = "OCID of the created VCN."
  value       = oci_core_vcn.this.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet (null if not created)."
  value       = var.public_subnet_cidr != null ? oci_core_subnet.public[0].id : null
}

output "private_subnet_id" {
  description = "OCID of the private subnet (null if not created)."
  value       = var.private_subnet_cidr != null ? oci_core_subnet.private[0].id : null
}
