
locals {
  default_master = {
    cpu       = 1
    vcpu      = 2
    memory    = 2048
    disk_size = 5120

    name_prefix = "talos master "
    name_suffix = ""

    hostname_prefix = "talos-master-"
    hostname_suffix = ""

    talos_configs = []
  }
  master_nodes = try(var.master_nodes, local.default_master)
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    time_sleep.vm_boot_cooldown
  ]
  for_each                    = tomap({ for i, master in opennebula_virtual_machine.talos_master : i => master })
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.nic[0].computed_ip
  config_patches              = local.master_nodes.talos_configs
}

resource "talos_machine_bootstrap" "controlplane" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
  for_each             = tomap({ for i, master in opennebula_virtual_machine.talos_master : i => master })
  node                 = each.value.nic[0].computed_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "controlplane" {
  depends_on = [
    talos_machine_bootstrap.controlplane
  ]
  for_each             = tomap({ for i, master in opennebula_virtual_machine.talos_master : i => master })
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = each.value.nic[0].computed_ip
}

resource "opennebula_virtual_machine" "talos_master" {
  count = var.master_nodes.instances
  name  = "${local.master_nodes.name_prefix}${count.index}${local.master_nodes.name_suffix}"

  cpu    = local.master_nodes.cpu
  vcpu   = local.master_nodes.vcpu
  memory = local.master_nodes.memory
  raw {
    type = "kvm"
    data = "<cpu mode='host-passthrough'></cpu>"
  }

  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
  }

  context = {
    HOSTNAME = "${local.master_nodes.hostname_prefix}${count.index}${local.master_nodes.hostname_suffix}"
    NETWORK  = "YES"
    TARGET   = "hda"
  }

  cpumodel {
    model = "host-passthrough"
  }

  #   tags = {
  #     service     = "talos"
  #     role        = "master"
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
    size     = local.master_nodes.disk_size
  }

  nic {
    model      = "virtio"
    network_id = var.network_id
  }

  hard_shutdown = true
}