variable "cluster_name" {
  default = "GeekZoneCluster"
}

variable "administrator_login" {
}

variable "administrator_login_password" {
}

variable "location" {
  default = "UK South"
}

variable "kubernetes_version" {
  default = "1.29.4"
}

variable "orchestrator_version" {
  default = "1.29.4"
}

variable "project_id" {
  type    = string
  default = "f8647d4c-9bf3-44d0-8c84-18a5ab9ee572"
}

variable "subscription_id" {
  type    = string
  default = "4bd8a672-d15d-44f5-a01c-bbcfbc0bd185"
}
