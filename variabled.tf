#Input variables (CIDR blocks, instance types, etc) for flexibility and reusabilityurces (VPC,EC2,etc)

variable "region" {
  default = "eu-west-1"
}

variable "ami_id" {
  default = "ami-0acd9df3b9de89f9b"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "firstkeypair"
}