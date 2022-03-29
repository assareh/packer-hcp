packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "ubuntu-focal-west-1" {
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

source "amazon-ebs" "ubuntu-focal-west-1" {
  assume_role {
    role_arn     = var.aws_packer_role
    session_name = "Packer"
  }
  region         = "us-west-1"
  source_ami     = data.amazon-ami.ubuntu-focal-west-1.id
  instance_type  = "t2.micro"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "${var.prefix}-ubuntu-20.04-{{timestamp}}"

  tags = {
    owner     = "${var.owner}"
    purpose   = "${var.purpose}"
    se-region = "${var.se-region}"
    terraform = "${var.terraform}"
    ttl       = "${var.ttl}"
  }
}

data "amazon-ami" "ubuntu-focal-west-2" {
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

source "amazon-ebs" "ubuntu-focal-west-2" {
  assume_role {
    role_arn     = var.aws_packer_role
    session_name = "Packer"
  }
  region         = "us-west-2"
  source_ami     = data.amazon-ami.ubuntu-focal-west-2.id
  instance_type  = "t2.micro"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "${var.prefix}-ubuntu-20.04-{{timestamp}}"

  tags = {
    owner     = "${var.owner}"
    purpose   = "${var.purpose}"
    se-region = "${var.se-region}"
    terraform = "${var.terraform}"
    ttl       = "${var.ttl}"
  }
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
    "source.amazon-ebs.ubuntu-focal-west-1",
    "source.amazon-ebs.ubuntu-focal-west-2"
  ]

  provisioner "file" {
    destination = "/home/ubuntu/"
    source      = "./scripts/deploy_app.sh"
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
      "PLACEHOLDER=picsum.photos WIDTH=1920 HEIGHT=1200 PREFIX=Andy ./deploy_app.sh"
    ]
  }
}
