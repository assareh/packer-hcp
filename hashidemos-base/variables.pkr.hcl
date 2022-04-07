# Read the documentation for locals blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/locals
locals {
  // consul_gossip   = vault("/packer/data/consul", "gossip")
  // consul_license  = vault("/packer/data/consul", "license")
  // esxi_password   = vault("/packer/data/esxi", "esxi_password")
  // esxi_username   = vault("/packer/data/esxi", "esxi_username")
  // nomad_gossip    = vault("/packer/data/nomad", "gossip")
  // nomad_license   = vault("/packer/data/nomad", "license")
  // ssh_password    = vault("/packer/data/ubuntu", "castle")
  // timestamp       = regex_replace(timestamp(), "[- TZ:]", "")
  // vault_license   = vault("/packer/data/vault", "license")
  // vm_name         = "Castle-${local.timestamp}"
}

# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.

# Read the documentation for variable blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/variable
variable "cni_version" {
  type    = string
  default = "1.0.1"
}

variable "consul_version" {
  type    = string
  default = "1.11.4+ent"
}

variable "containerd_version" {
  type    = string
  default = "0.9.2"
}

variable "nomad_version" {
  type    = string
  default = "1.2.6+ent"
}

variable "vault_version" {
  type    = string
  default = "1.9.4+ent"
}









variable "arm_client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "arm_client_secret" {
  type      = string
  default   = "${env("ARM_CLIENT_SECRET")}"
  sensitive = true
}

variable "arm_subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "aws_packer_role" {
  type        = string
  description = "This is an AWS role with sufficient privileges for Packer that can be assumed."
}

variable "hcp_packer_bucket_name" {
  type        = string
  description = "Your HCP Packer Registry bucket name"
  default     = "hashidemos-base"
}

variable "owner" {
  type    = string
  default = "assareh"
}

variable "prefix" {
  type    = string
  default = "assareh-hashidemos"
}

variable "purpose" {
  type    = string
  default = "Demo Packer and Terraform"
}

variable "rg_name" {
  type    = string
  default = "assareh-hashidemos"
}

variable "se-region" {
  type    = string
  default = "AMER - West E2 - R2"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "terraform" {
  type    = string
  default = "true"
}

variable "ttl" {
  type    = string
  default = "-1"
}
