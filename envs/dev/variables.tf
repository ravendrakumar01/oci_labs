variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

# Used only if you enable the Autonomous Database example (module.database).
# Provide via TF_VAR_db_admin_password (a GitHub secret), never hardcode.
variable "db_admin_password" {
  type        = string
  description = "ADMIN password for Autonomous Database (12-30 chars)."
  default     = null
  sensitive   = true
}

# SSH public key injected into instances at launch (for SSH login).
# Provide via TF_VAR_ssh_public_key (GitHub secret OCI_SSH_PUBLIC_KEY).
variable "ssh_public_key" {
  type        = string
  description = "SSH public key content for VM login."
  default     = null
}
