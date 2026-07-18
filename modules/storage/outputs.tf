output "volume_ids" {
  description = "Map of block volume name => OCID."
  value       = { for k, v in oci_core_volume.this : k => v.id }
}

output "bucket_names" {
  description = "List of created bucket names."
  value       = [for b in oci_objectstorage_bucket.this : b.name]
}

output "namespace" {
  description = "Object Storage namespace."
  value       = data.oci_objectstorage_namespace.ns.namespace
}
