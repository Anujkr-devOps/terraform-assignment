#Input variables (CIDR blocks, instance types, etc) for flexibility and reusabilityurces (VPC,EC2,etc)

variable "region" {
  default = "eu-west-1"
}

variable "ami_id" {
  default = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "firstkeypair"
}