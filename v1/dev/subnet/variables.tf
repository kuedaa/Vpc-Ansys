variable "region" {
  type        = string
  default     = "us-east-1" 
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "env" {
  default = "Dev"
}


variable "number_subnet" {
  default = 3
}

variable "cidr_private_subnet" {
  default =  ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
}

variable "cidr_public_subnet" {
  default =  ["10.0.128.0/19", "10.0.160.0/19", "10.0.192.0/19"]
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-0c7217cdde317cfec"
}