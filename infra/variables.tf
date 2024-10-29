variable "tag_prefix" {
  description = "default prefix of names"
}

variable "subscription_id" {
  description = "subscription id for azure"
}

variable "vnet_cidr" {
  description = "which private subnet do you want to use for the VPC. Subnet mask of /16"
}

variable "postgres_user" {
  description = "postgresql user"
}

variable "postgres_password" {
  description = "password postgresql user"
}

variable "storage_account" {
  description = "name of the storage account"
}

