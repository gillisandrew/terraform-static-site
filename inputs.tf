variable "project" {
  type        = string
  default     = "example"
  description = "A meaningful project name"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment (e.g. prod, dev, test)"
}

variable "domain" {
  type        = string
  description = "Domain to serve the site under"
}

variable "hosted_zone_id" {
  type = string
}

variable "index_document" {
  type    = string
  default = "index.html"
}