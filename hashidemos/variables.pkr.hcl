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
  default     = "hashidemos"
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
