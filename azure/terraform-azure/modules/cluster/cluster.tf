resource "azurerm_resource_group" "geekzone" {
  name     = "geekzone"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "GeekZoneCluster" {
  name                  = "GeekZoneCluster"
  location              = azurerm_resource_group.geekzone.location
  resource_group_name   = azurerm_resource_group.geekzone.name
  dns_prefix            = "gz"            
  kubernetes_version    =  var.kubernetes_version
  
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_E4s_v3"
    type       = "VirtualMachineScaleSets"
    os_disk_size_gb = 30
  }

  service_principal  {
    client_id = var.client_id
    client_secret = var.client_secret
  }

  linux_profile {
    admin_username = "gzuser"
    ssh_key {
        key_data = var.ssh_key
    }
  }

  network_profile {
      network_plugin = "kubenet"
      load_balancer_sku = "Standard"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled = false
    }
  }

}

