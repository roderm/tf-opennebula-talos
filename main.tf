terraform {
  required_providers {
    opennebula = {
      source  = "OpenNebula/opennebula"
      version = "1.4.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.6.0-alpha.1"
    }
  }
}

# cooldown for VMs
resource "time_sleep" "vm_boot_cooldown" {
  # make sure VMs are booted
  depends_on = [opennebula_virtual_machine.talos_master, opennebula_virtual_machine.talos_agent]

  create_duration = "30s"
}

# cooldown for cluster deployment
resource "time_sleep" "talos_deploy_cooldown" {
  # make sure cluster had enough time to properly deploy
  depends_on = [talos_machine_bootstrap.controlplane]

  create_duration = "2m"
}