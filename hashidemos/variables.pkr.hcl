variable "aws_packer_role" {
  type = string
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

variable "se-region" {
  type    = string
  default = "AMER - West E2 - R2"
}

variable "terraform" {
  type    = string
  default = "true"
}

variable "ttl" {
  type    = string
  default = "-1"
}
