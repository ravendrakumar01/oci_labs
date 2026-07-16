output "compute_public_ips" {
  description = "Public IPs of dev compute instances."
  value       = module.compute.public_ips
}

output "compute_private_ips" {
  description = "Private IPs of dev compute instances."
  value       = module.compute.private_ips
}
