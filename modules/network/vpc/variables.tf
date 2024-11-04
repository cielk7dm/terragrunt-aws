variable "azs" {
    type = list(string)
}

variable "map_public_ip_on_launch" {
    default = false
}

variable "private_subnet_private_dns_hostname_type_on_launch" {
    default = false
}

variable "private_subnet_suffix" {
    default = "private-subnet"
}

variable "public_subnet_suffix" {
    default = "public-subnet"
}

variable "name" {}

variable "vpc_cidr" {}

variable "enable_dns_hostnames" {
    default = true
}

variable "enable_dns_support" {
    default = true
}

variable "single_nat" {
    default = true
}

variable "enable_nat" {
  default = false
}

variable "tags" {
  type = map
}