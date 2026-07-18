output "database_ids" {
  description = "Map of database display name => OCID."
  value       = { for k, v in oci_database_autonomous_database.this : k => v.id }
}

output "connection_strings" {
  description = "Map of database display name => connection strings."
  value       = { for k, v in oci_database_autonomous_database.this : k => v.connection_strings }
  sensitive   = true
}
