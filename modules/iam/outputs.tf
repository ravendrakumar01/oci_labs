output "group_ids" {
  description = "Map of group name => OCID."
  value       = { for k, v in oci_identity_group.this : k => v.id }
}

output "policy_ids" {
  description = "Map of policy name => OCID."
  value       = { for k, v in oci_identity_policy.this : k => v.id }
}
