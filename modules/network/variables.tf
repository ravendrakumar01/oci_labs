variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID where the compartment will be created."
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming all resources (e.g. DEV, PROD, TEST)."
}

variable "compartment_name" {
  type        = string
  description = "Name of the compartment to create."
}

variable "compartment_description" {
  type        = string
  description = "Description of the compartment."
  default     = ""
}

variable "vcn_cidr" {
  type        = string
  description = "CIDR block for the VCN."
}

variable "vcn_dns_label" {
  type        = string
  description = "DNS label for the VCN."
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the public/primary subnet. Set to null to skip."
  default     = null
}

variable "public_subnet_display_name" {
  type        = string
  description = "Override display name for the public subnet. Defaults to <PREFIX>_PUB_SUBNET."
  default     = null
}

variable "public_subnet_dns_label" {
  type        = string
  description = "Override DNS label for the public subnet. Defaults to <prefix>pub."
  default     = null
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for the private subnet. Set to null to skip."
  default     = null
}

variable "private_subnet_display_name" {
  type        = string
  description = "Override display name for the private subnet. Defaults to <PREFIX>_PRIV_SUBNET."
  default     = null
}

variable "private_subnet_dns_label" {
  type        = string
  description = "Override DNS label for the private subnet. Defaults to <prefix>priv."
  default     = null
}

variable "enable_internet_gateway" {
  type        = bool
  description = "Create an Internet Gateway + public route table (routes 0.0.0.0/0 to IGW)."
  default     = false
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create a NAT Gateway + private route table (routes 0.0.0.0/0 to NAT)."
  default     = false
}

variable "ingress_tcp_ports" {
  type        = list(number)
  description = "List of TCP ports to allow inbound from 0.0.0.0/0. Empty means no custom security list is created."
  default     = []
}
