terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Criação da vm Linux
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

# Criação do servidor K8s
resource "digitalocean_kubernetes_cluster" "k8s-digitalocean" {
  name    = "k8s-digitalocean"
  region  = var.region
  version = "1.25.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2

  }
}

#Variaveis
variable "region" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

variable "do_token" {
  default = ""
}

#outpus
output "jenkins_ip" {
  
    value = digitalocean_droplet.jenkins.ipv4_address

}

#Conexão servidor K8s
resource "local_file" "foo" {
  content  = digitalocean_kubernetes_cluster.k8s-digitalocean.kube_config.0.raw_config
  filename = "kube_config.yaml"
}