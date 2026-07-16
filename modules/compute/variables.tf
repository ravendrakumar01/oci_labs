variable "compartment_id" {
  type        = string
  description = "Compartment OCID where instances will be created."
}

variable "instances" {
  description = <<-EOT
    Map of instances to create. The map KEY becomes the instance display name.
    Each instance supports:
      - availability_domain (required)  e.g. "xxxx:AP-MUMBAI-1-AD-1"
      - shape               (required)  e.g. "VM.Standard.E4.Flex"
      - image_id            (required)  OCID of the image
      - subnet_id           (required)  OCID of the subnet
      - ocpus               (flex only) default 1
      - memory_in_gbs       (flex only) default 8
      - assign_public_ip    default false
      - ssh_public_key      default null (contents of a .pub key)
      - boot_volume_size_gbs default null (uses image default)
      - freeform_tags       default {}
  EOT
  type = map(object({
    availability_domain  = string
    shape                = string
    image_id             = string
    subnet_id            = string
    ocpus                = optional(number, 1)
    memory_in_gbs        = optional(number, 8)
    assign_public_ip     = optional(bool, false)
    ssh_public_key       = optional(string)
    boot_volume_size_gbs = optional(number)
    freeform_tags        = optional(map(string), {})
  }))
  default = {}
}
