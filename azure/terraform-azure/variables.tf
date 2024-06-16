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
