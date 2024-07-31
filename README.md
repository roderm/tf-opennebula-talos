# tf-opennebula-talos
Create a [Talos cluster]() on [OpenNebula]() with this [Terraform]() module.

## Requirements
* OpenNebula environment with KVM and a Network configured to reach the internet.
* A talos-opennebula image importet to you storage. The image can be downloaded from the [talos releas page](https://github.com/siderolabs/talos/releases) with prefix `opennebula`(after v1.7.5)

## Usage
minimal parameters are:
* `name`: cluster name
* `image_id`: talos image in the datastore
* `network_id`: network to use
* `master_nodes.instances`: number of masters to setup
* `agent_nodes.instances`: number of agents to setup

```hcl
data "opennebula_image" "talos" {
  name = "talos-opennebula-amd64"
}

data "opennebula_virtual_network" "public" {
  name = "public"
}

module "cluster" {
  source     = "git@github.com:roderm/tf-opennebula-talos"
  name       = "example"
  image_id   = opennebula_image.talos.id
  network_id = opennebula_virtual_network.public.id
  master_nodes = {
    instances = 1
  }
  agent_nodes = {
    instances = 3
  }
}
```
Configure the kubernetes provider:
```hcl
locals {
  kubeconfig = yamldecode(module.cluster.kubeconfig)
}

provider "kubernetes" {
  host                   = local.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data)

  client_certificate = base64decode(local.kubeconfig.users[0].user.client-certificate-data)
  client_key         = base64decode(local.kubeconfig.users[0].user.client-key-data)
}
```