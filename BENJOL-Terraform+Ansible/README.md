# DigitalOcean Terraform and Ansible Demo

This repository contains [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) configurations to launch and set up some basic infrastructure on DigitalOcean. As server deployments and development teams continue to get larger and more complex, the practice of defining infrastructure as version-controlled code has taken off. Tools such as Ansible and Terraform allow you to clearly define the servers you need (and firewalls, load balancers, etc.) and the configuration of the operating system and software on those servers.

This will create the following infrastructure using Terraform:

- Two 1 GB Droplets in the SGP1 datacenter running Ubuntu 20.04
- One DigitalOcean Load Balancer to route HTTP traffic to the Droplets
- One DigitalOcean Cloud Firewall to lock down communication between the Droplets and the outside world

Then use Ansible to run the following tasks on Droplet:

- Update all packages
- Install the DigitalOcean monitoring agent, to enable resource usage graphs in the Control Panel
- Install the Nginx web server software
- Install a demo `index.html` that shows Sammy and the Droplet's hostname
