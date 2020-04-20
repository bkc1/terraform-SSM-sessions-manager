# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
#  version = "~> 0.1"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

terraform {
  required_version = ">= 0.12.6"
}

data "aws_ami" "amznlinux2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Amazon
}

# This will fetch our account_id, no need to hard code it
data "aws_caller_identity" "current" {}
