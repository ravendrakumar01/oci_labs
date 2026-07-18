variable "compartment_id" {
  type        = string
  description = "Compartment OCID for the load balancer."
}

variable "display_name" {
  type        = string
  description = "Display name for the load balancer."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet OCID(s) the load balancer lives in."
}

variable "is_private" {
  type        = bool
  description = "true = private LB, false = public (internet-facing)."
  default     = false
}

variable "min_mbps" {
  type        = number
  description = "Flexible shape minimum bandwidth (Always-Free = 10)."
  default     = 10
}

variable "max_mbps" {
  type        = number
  description = "Flexible shape maximum bandwidth (Always-Free = 10)."
  default     = 10
}

variable "listener_port" {
  type        = number
  description = "Port the LB listens on (front-end)."
  default     = 80
}

variable "listener_protocol" {
  type        = string
  description = "Listener protocol: HTTP or TCP."
  default     = "HTTP"
}

variable "backend_port" {
  type        = number
  description = "Port on the backend VMs traffic is forwarded to."
  default     = 80
}

variable "backends" {
  description = <<-EOT
    Map of backends. KEY = a static name (e.g. instance name).
      - ip   : backend VM private IP (can be known-after-apply)
      - port : optional per-backend port (defaults to backend_port)
  EOT
  type = map(object({
    ip   = string
    port = optional(number)
  }))
  default = {}
}

variable "health_check_protocol" {
  type        = string
  description = "Health check protocol: HTTP or TCP."
  default     = "HTTP"
}

variable "health_check_url" {
  type        = string
  description = "URL path for HTTP health checks."
  default     = "/"
}
