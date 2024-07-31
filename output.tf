data "talos_client_configuration" "talos_config" {
  depends_on = [
    time_sleep.talos_deploy_cooldown
  ]
  cluster_name         = var.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = tolist([for i, master in concat(opennebula_virtual_machine.talos_master, opennebula_virtual_machine.talos_agent) : master.nic[0].computed_ip])
}

output "talosconfig" {
  value     = data.talos_client_configuration.talos_config.talos_config
  sensitive = true
}

data "talos_cluster_kubeconfig" "kube_config" {
  depends_on = [
    time_sleep.talos_deploy_cooldown
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = opennebula_virtual_machine.talos_master[0].nic[0].computed_ip
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kube_config.kubeconfig_raw
  sensitive = true
}

output "master_nodes" {
  value     = opennebula_virtual_machine.talos_master
  sensitive = false
}

output "agent_nodes" {
  value     = opennebula_virtual_machine.talos_agent
  sensitive = false
}
