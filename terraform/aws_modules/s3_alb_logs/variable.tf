variable "bucket_name" {
  type = string
}
variable "bucket_prefix" {
  type = string
}

variable "bucket_rule_id" {
  type = string
}

variable "bucket_exp_days" {
  type = number
  default = 60
}
