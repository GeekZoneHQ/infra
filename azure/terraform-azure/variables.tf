variable "cluster_name" {
  default = "GeekZoneCluster"
}

variable "administrator_login" {
}

variable "administrator_login_password" {
}

variable "HCP_CLIENT_ID" {
}

variable "HCP_CLIENT_SECRET" {
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
