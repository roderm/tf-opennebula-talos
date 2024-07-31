variable "name" {
  type = string
}
variable "image_id" {
  type        = number
  description = "Opennebula Image ID of the talos image (Import from: https://github.com/siderolabs/talos/releases)"
}

variable "network_id" {
  type        = number
  description = "Opennebula Network ID for the VMs"
}

variable "endpoint" {
  type        = string
  default     = ""
  description = "The Talos endpoint hostname to be configuered (e.g. 192.168.0.120). If left empty, the IP of the first master will be used."
}

variable "endpoint_port" {
  type        = number
  default     = 6443
  description = "The Talos endpoint port"
}

variable "master_nodes" {
  type = object({
    instances = number
    cpu       = optional(number)
    vcpu      = optional(number)
    memory    = optional(number)
    disk_size = optional(number)

    name_prefix = optional(string)
    name_suffix = optional(string)

    hostname_prefix = optional(string)
    hostname_suffix = optional(string)

    talos_configs = optional(list(string))
  })
}

variable "agent_nodes" {
  type = object({
    instances = number
    cpu       = optional(number)
    vcpu      = optional(number)
    memory    = optional(number)
    disk_size = optional(number)

    name_prefix = optional(string)
    name_suffix = optional(string)

    hostname_prefix = optional(string)
    hostname_suffix = optional(string)

    talos_configs = optional(list(string))
  })
}