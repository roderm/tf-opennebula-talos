resource "talos_machine_secrets" "this" {}

locals {
  endpoint_host = var.endpoint == "" ? opennebula_virtual_machine.talos_master[0].nic[0].computed_ip : var.endpoint
  endpoint      = "https://${local.endpoint_host}:${var.endpoint_port}"
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.name
  machine_type     = "controlplane"
  cluster_endpoint = local.endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "controlplane" {
  cluster_name         = var.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = tolist([for i, master in opennebula_virtual_machine.talos_master : master.nic[0].computed_ip])
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.name
  machine_type     = "worker"
  cluster_endpoint = local.endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "worker" {
  cluster_name         = var.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = tolist([for i, agent in opennebula_virtual_machine.talos_agent : agent.nic[0].computed_ip])
}