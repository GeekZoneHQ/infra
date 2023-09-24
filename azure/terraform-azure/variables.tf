variable "ARM_CLIENT_ID" {
}

variable "ARM_CLIENT_SECRET" {
}

variable "ARM_TENANT_ID" {
}

variable "ARM_SUBSCRIPTION_ID" {
}

variable "administrator_login" {
  default = "postgres"
}

variable "administrator_login_password" {
  default = "Yqp&@^vBeeM8ZiggS$ez"
}

variable "location" {
  default = "UK South"
}

variable "kubernetes_version" {
  default = "1.27.1"
}

variable "orchestrator_version" {
  default = "1.27.1"
}
