packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/azure"
    }
  }
}

data "amazon-ami" "ubuntu-focal-west-us-1" {
  assume_role {
    role_arn     = var.aws_packer_role
    session_name = "Packer"
  }
  region = "us-west-1"
  filters = {
    name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-focal-west-us-1" {
  assume_role {
    role_arn     = var.aws_packer_role
    session_name = "Packer"
  }
  region         = "us-west-1"
  source_ami     = data.amazon-ami.ubuntu-focal-west-us-1.id
  instance_type  = "t3a.small"
  ssh_username   = var.ssh_username
  ssh_agent_auth = false
  ami_name       = "${var.prefix}-ubuntu-20.04-{{timestamp}}"

  tags = {
    owner     = var.owner
    purpose   = var.purpose
    se-region = var.se-region
    terraform = var.terraform
    ttl       = var.ttl
  }
}

data "amazon-ami" "ubuntu-focal-west-us-2" {
  assume_role {
    role_arn     = var.aws_packer_role
    session_name = "Packer"
  }
  region = "us-west-2"
  filters = {
    name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-focal-west-us-2" {
  assume_role {
    role_arn     = var.aws_packer_role
    session_name = "Packer"
  }
  region         = "us-west-2"
  source_ami     = data.amazon-ami.ubuntu-focal-west-us-2.id
  instance_type  = "t3a.small"
  ssh_username   = var.ssh_username
  ssh_agent_auth = false
  ami_name       = "${var.prefix}-ubuntu-20.04-{{timestamp}}"

  tags = {
    owner     = var.owner
    purpose   = var.purpose
    se-region = var.se-region
    terraform = var.terraform
    ttl       = var.ttl
  }
}

source "azure-arm" "ubuntu-focal-west-us-2" {
  azure_tags = {
    owner     = var.owner
    purpose   = var.purpose
    se-region = var.se-region
    terraform = var.terraform
    ttl       = var.ttl
  }

  client_id                         = var.arm_client_id
  client_secret                     = var.arm_client_secret
  image_offer                       = "0001-com-ubuntu-server-focal"
  image_publisher                   = "Canonical"
  image_sku                         = "20_04-lts"
  location                          = "West US 2"
  managed_image_name                = "${var.prefix}-ubuntu-20.04-{{timestamp}}"
  managed_image_resource_group_name = var.rg_name
  os_type                           = "Linux"
  ssh_username                      = var.ssh_username
  subscription_id                   = var.arm_subscription_id
  vm_size                           = "Standard_B2s"
}

build {
  hcp_packer_registry {
    bucket_name = "hashidemos"
    description = <<EOT
This is the Ubuntu 20.04 hashidemos image.
It has a simple webserver on http:80.
    EOT
    bucket_labels = {
      "organization" = "hashidemos",
      "team"         = "devopsfu",
      "os"           = "Ubuntu 20.04"
    }
    build_labels = {
      "organization" = "hashidemos",
      "team"         = "devopsfu",
      "os"           = "Ubuntu 20.04"
    }
  }

  sources = [
    "source.amazon-ebs.ubuntu-focal-west-us-1",
    "source.amazon-ebs.ubuntu-focal-west-us-2",
    "source.azure-arm.ubuntu-focal-west-us-2",
  ]

  provisioner "file" {
    destination = "/home/${var.ssh_username}/"
    source      = "files/"
  }

  provisioner "shell" {
    inline = [
      # this is not working for some reason, switching to github installation
      # "sudo apt-get update && sudo apt-get install jq",
      "curl -O https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && sudo mv jq-linux64 /usr/local/bin/jq",
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      # this is from the hashicorp documentation, but was not working here for some reason, replaced with echo
      # "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "echo \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y software-properties-common curl nginx vim git wget",
      "sudo apt-get install -y nomad-enterprise=${var.nomad_version} vault-enterprise=${var.vault_version} consul-enterprise=${var.consul_version}",
      "sudo apt-get autoremove -y",
      "sudo -H -u ${var.ssh_username} nomad -autocomplete-install",
      "sudo -H -u ${var.ssh_username} consul -autocomplete-install",
      "sudo -H -u ${var.ssh_username} vault -autocomplete-install"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/cni/bin/",
      "curl -LO https://github.com/containernetworking/plugins/releases/download/v${var.cni_version}/cni-plugins-linux-amd64-v${var.cni_version}.tgz",
      "sudo tar -xzf cni-plugins-linux-amd64-v${var.cni_version}.tgz -C /opt/cni/bin/"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt install -y apt-transport-https gnupg",
      "curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/getenvoy.list",
      "sudo apt update",
      "sudo apt install -y getenvoy-envoy"
    ]
  }

  provisioner "shell" {
    inline = [
      "chmod +x deploy_website.sh",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "PLACEHOLDER=picsum.photos WIDTH=1920 HEIGHT=1200 PREFIX=${var.prefix} ./deploy_website.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo mv /home/${var.ssh_username}/nomad.hcl /etc/nomad.d/.",
      "sudo chown -R nomad:nomad /etc/nomad.d",
    ]
  }

 provisioner "shell" {
    inline = [
      "sudo chown -R nomad:nomad /opt/nomad",
      "sudo chmod -R 700 /opt/nomad"
    ]
  }
  }
