variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  default = "us-west-2"
}

variable "delegation_set" {}

variable "private_key" {
  default = "mykey"
}

variable "public_key" {
  default = "mykey.pub"
}

variable "db_pass" {
  default = "redhat11"
}

variable "db_user" {
  default = "admin"
}

variable "db_name" {
  default = "wpdb"
}
