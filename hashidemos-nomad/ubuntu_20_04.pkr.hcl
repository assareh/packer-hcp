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

data "hcp-packer-iteration" "hashidemos" {
  bucket_name = "hashidemos"
  channel     = "production"
}

data "hcp-packer-image" "hashidemos-west-us-2" {
  bucket_name    = "hashidemos"
  iteration_id   = data.hcp-packer-iteration.hashidemos.id
  cloud_provider = "aws"
  region         = "us-west-2"
}

source "amazon-ebs" "ubuntu-focal-west-us-2" {
  assume_role {
    role_arn     = var.aws_packer_role
    session_name = "Packer"
  }
  region         = "us-west-2"
  source_ami     = data.hcp-packer-image.hashidemos-west-us-2.id
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

build {
  hcp_packer_registry {
    bucket_name = var.hcp_packer_bucket_name
    description = <<EOT
This is the Ubuntu 20.04 hashidemos image.
It has Consul, Nomad, and Vault installed.
Also Docker, configured for Nomad server.
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
    "source.amazon-ebs.ubuntu-focal-west-us-2",
  ]

  provisioner "file" {
    destination = "/home/${var.ssh_username}/"
    source      = "files/"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get install -y docker.io",
      "sudo apt-get autoremove -y",
    ]
  }
}
