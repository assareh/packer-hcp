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
This is the Ubuntu 20.04 hashidemos base image.
It has Consul, Nomad, and Vault installed.
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
    #    "source.amazon-ebs.ubuntu-focal-west-us-1",
    "source.amazon-ebs.ubuntu-focal-west-us-2",
    #    "source.azure-arm.ubuntu-focal-west-us-2",
  ]

  provisioner "file" {
    destination = "/home/${var.ssh_username}/"
    source      = "files/"
  }

  provisioner "shell" {
    inline = [
      # this is not working for some reason, switching to github installation
      # "sudo apt-get update && sudo apt-get install jq",
      "curl -LO https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && sudo mv jq-linux64 /usr/local/bin/jq",
      "sudo chown root:root /usr/local/bin/jq && sudo chmod +x /usr/local/bin/jq",
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      # this is from the hashicorp documentation, but was not working here for some reason, replaced with echo
      # "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "echo \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y curl vim git wget",
      "sudo apt-get install -y nomad-enterprise=${var.nomad_version} vault-enterprise=${var.vault_version} consul-enterprise=${var.consul_version}",
      "sudo apt-get autoremove -y",
      "sudo -H -u ${var.ssh_username} nomad -autocomplete-install",
      "sudo -H -u ${var.ssh_username} consul -autocomplete-install",
      "sudo -H -u ${var.ssh_username} vault -autocomplete-install"
    ]
  }
}
