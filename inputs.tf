variable "project" {
  type    = string
  default = "example"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "domain" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}