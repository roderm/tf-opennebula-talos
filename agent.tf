
locals {
  default_agent = {
    instances = 1

    cpu       = 1
    vcpu      = 2
    memory    = 2048
    disk_size = 5120

    name_prefix = "talos agent "
    name_suffix = ""

    hostname_prefix = "talos-agent-"
    hostname_suffix = ""

    talos_configs = []
  }
  agent_nodes = try(var.agent_nodes, local.default_agent)
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    talos_machine_bootstrap.controlplane
  ]
  for_each                    = tomap({ for i, agent in opennebula_virtual_machine.talos_agent : i => agent })
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.nic[0].computed_ip
  config_patches              = local.agent_nodes.talos_configs
}

resource "opennebula_virtual_machine" "talos_agent" {
  depends_on = [
    // just to make auto IP more logical
    opennebula_virtual_machine.talos_master
  ]
  count = var.agent_nodes.instances
  name  = "${local.agent_nodes.name_prefix}${count.index}${local.agent_nodes.name_suffix}"

  cpu    = local.agent_nodes.cpu
  vcpu   = local.agent_nodes.vcpu
  memory = local.agent_nodes.memory
  raw {
    type = "kvm"
    data = "<cpu mode='host-passthrough'></cpu>"
  }

  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
  }

  context = {
    HOSTNAME = "${local.agent_nodes.hostname_prefix}${count.index}${local.agent_nodes.hostname_suffix}"
    NETWORK  = "YES"
    TARGET   = "hda"
  }

  cpumodel {
    model = "host-passthrough"
  }

  #   tags = {
  #     service     = "talos"
  #     role        = "agent"
  #     environment = "${terraform.workspace}"
  #   }

  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    image_id = var.image_id
    target   = "vda"
    driver   = "qcow2"
    size     = local.agent_nodes.disk_size
  }

  nic {
    model      = "virtio"
    network_id = var.network_id
  }

  hard_shutdown = true
}