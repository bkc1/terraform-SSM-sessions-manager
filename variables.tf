
variable "public_key_path" {
  description = "Enter path to the public key"
  default     = "keys/mykey.pub"
}

variable "key_name" {
  description = "Enter name of private key"
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region to launch servers"
  default     = "us-west-2"
}

variable "app_prefix" {
  description = "Application abbreviation/prefix"
  default     = "demo1"
}

variable "env" {
  default = "dev"
}

variable "domain_name" {
  default = "aws-dev.example.io"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/21"
}

variable "subnet1" {
  default = "10.0.1.0/24"
}
