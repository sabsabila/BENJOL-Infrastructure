variable "do_token" { }

variable "ssh_fingerprint" { }

provider "digitalocean" {
  token = var.do_token
}

# create droplet
resource "digitalocean_droplet" "benjol-s1" {
  image    = "ubuntu-20-04-x64"
  name     = "benjol-s1"
  region   = "sgp1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_fingerprint]
}

# create a loadbalancer
resource "digitalocean_loadbalancer" "benjol-lb" {
  name   = "benjol-lb"
  region = "sgp1"

  droplet_ids = [
    digitalocean_droplet.benjol-s1.id,
  ]

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }
}

# create a firewall that only accepts port 80 traffic from the load balancer
resource "digitalocean_firewall" "benjol-firewall" {
  name = "benjol-firewall"

  droplet_ids = [
    digitalocean_droplet.benjol-s1.id,
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol                  = "tcp"
    port_range                = "80"
    source_load_balancer_uids = [digitalocean_loadbalancer.benjol-lb.id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
}

# create record to the domain

resource "digitalocean_domain" "default" {
    name = "benjol.bike"
}

resource "digitalocean_record" "all" {
    domain = digitalocean_domain.default.name
    type   = "A"
    name   = "@"
    value  = digitalocean_droplet.benjol-s1.ipv4_address
}

resource "digitalocean_record" "api" {
    domain = digitalocean_domain.default.name
    type   = "A"
    name   = "api"
    value  = digitalocean_droplet.benjol-s1.ipv4_address
}


# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = [
    digitalocean_droplet.benjol-s1
  ]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.benjol-s1.name} ansible_host=${digitalocean_droplet.benjol-s1.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' > inventory"
  }

}

output the load balancer ip
output "ip_lb" {
  value = digitalocean_loadbalancer.benjol-lb.ip
}

# output the server ip
output "ip_s1" {
  value = digitalocean_droplet.benjol-s1.ipv4_address
}

# Output the FQDN for the www A record.
output "www_fqdn" {
  value = digitalocean_record.www.fqdn
}

# Output the FQDN for the api A record.
output "api_fqdn" {
  value = digitalocean_record.api.fqdn
}
