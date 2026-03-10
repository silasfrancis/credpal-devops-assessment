
variable "tags" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ec2_instance_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}