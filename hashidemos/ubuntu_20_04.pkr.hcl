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
  instance_type  = "t2.micro"
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
  instance_type  = "t2.micro"
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
  vm_size                           = "Standard_B1s"
}

build {
  hcp_packer_registry {
    bucket_name = "hashidemos"
    description = <<EOT
This is the Ubuntu 20.04 hashidemos image.
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
    destination = "/home/ubuntu/"
    source      = "./scripts/deploy_website.sh"
  }

  provisioner "shell" {
    script = "./scripts/node_configure.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y autoremove",
      "sudo apt-get -y install software-properties-common curl jq nginx vim git wget python",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "chmod +x *.sh",
      "PLACEHOLDER=picsum.photos WIDTH=1920 HEIGHT=1200 PREFIX=${var.prefix} ./deploy_website.sh"
    ]
  }
}
