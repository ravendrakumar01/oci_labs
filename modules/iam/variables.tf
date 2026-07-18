variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID (groups live at tenancy level)."
}

variable "groups" {
  description = <<-EOT
    Map of IAM groups. KEY = group name.
      - description : group description
  EOT
  type = map(object({
    description = optional(string, "")
  }))
  default = {}
}

variable "policies" {
  description = <<-EOT
    Map of IAM policies. KEY = policy name.
      - compartment_id : compartment (or tenancy) the policy applies in
      - description    : policy description
      - statements     : list of policy statements (e.g.
                         "Allow group DEV-admins to manage all-resources in compartment DEV")
  EOT
  type = map(object({
    compartment_id = string
    description    = optional(string, "")
    statements     = list(string)
  }))
  default = {}
}
