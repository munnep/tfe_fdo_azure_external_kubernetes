terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.88.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.5.3"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "acme" {
  # server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "azurerm_resource_group" "tfe" {
  name     = var.tag_prefix
  location = "North Europe"
}

resource "azurerm_virtual_network" "tfe" {
  name                = "${var.tag_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
}

resource "azurerm_subnet" "public1" {
  name                 = "${var.tag_prefix}-public1"
  resource_group_name  = azurerm_resource_group.tfe.name
  virtual_network_name = azurerm_virtual_network.tfe.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}

# resource "azurerm_subnet" "public2" {
#   name                 = "${var.tag_prefix}-public2"
#   resource_group_name  = azurerm_resource_group.tfe.name
#   virtual_network_name = azurerm_virtual_network.tfe.name
#   address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 2)]
# }

resource "azurerm_subnet" "private1" {
  name                 = "${var.tag_prefix}-private1"
  resource_group_name  = azurerm_resource_group.tfe.name
  virtual_network_name = azurerm_virtual_network.tfe.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 11)]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "private2" {
  name                 = "${var.tag_prefix}-private2"
  resource_group_name  = azurerm_resource_group.tfe.name
  virtual_network_name = azurerm_virtual_network.tfe.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 12)]
}

resource "azurerm_network_security_group" "tfe" {
  name                = "${var.tag_prefix}-nsg"
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name

  security_rule {
    name                       = "https"
    priority                   = "100"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = "110"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = "120"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "postgresql"
    priority                   = "130"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "redis_non_ssl"
    priority                   = "140"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "redis_ssl"
    priority                   = "150"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6380"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "tfe-public1" {
  subnet_id                 = azurerm_subnet.public1.id
  network_security_group_id = azurerm_network_security_group.tfe.id
}

# resource "azurerm_subnet_network_security_group_association" "tfe-public2" {
#   subnet_id                 = azurerm_subnet.public2.id
#   network_security_group_id = azurerm_network_security_group.tfe.id
# }

resource "azurerm_subnet_network_security_group_association" "tfe-private1" {
  subnet_id                 = azurerm_subnet.private1.id
  network_security_group_id = azurerm_network_security_group.tfe.id
}

resource "azurerm_subnet_network_security_group_association" "tfe-private2" {
  subnet_id                 = azurerm_subnet.private2.id
  network_security_group_id = azurerm_network_security_group.tfe.id
}

resource "azurerm_public_ip" "tfe" {
  name                = "${var.tag_prefix}-nat-publicIP"
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}


resource "azurerm_nat_gateway" "tfe" {
  name                    = "${var.tag_prefix}-nat-Gateway"
  location                = azurerm_resource_group.tfe.location
  resource_group_name     = azurerm_resource_group.tfe.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "tfe" {
  nat_gateway_id       = azurerm_nat_gateway.tfe.id
  public_ip_address_id = azurerm_public_ip.tfe.id
}

resource "azurerm_subnet_nat_gateway_association" "tfe_private1" {
  subnet_id      = azurerm_subnet.private1.id
  nat_gateway_id = azurerm_nat_gateway.tfe.id
}

resource "azurerm_private_dns_zone" "example" {
  name                = "${var.tag_prefix}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.tfe.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = var.tag_prefix
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.tfe.id
  resource_group_name   = azurerm_resource_group.tfe.name
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                   = "${var.tag_prefix}-psqlflexibleserver"
  resource_group_name    = azurerm_resource_group.tfe.name
  location               = azurerm_resource_group.tfe.location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.private1.id
  private_dns_zone_id    = azurerm_private_dns_zone.example.id
  administrator_login    = var.postgres_user
  administrator_password = var.postgres_password
  zone                   = "1"

  storage_mb = 32768

  sku_name   = "GP_Standard_D2s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]

}

resource "azurerm_postgresql_flexible_server_database" "example" {
  name      = "tfe"
  server_id = azurerm_postgresql_flexible_server.example.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_configuration" "example" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.example.id
  value     = "CITEXT,HSTORE,UUID-OSSP"
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account
  resource_group_name      = azurerm_resource_group.tfe.name
  location                 = azurerm_resource_group.tfe.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  routing {
    publish_microsoft_endpoints = true
    choice                      = "MicrosoftRouting"
  }

}

resource "azurerm_storage_container" "example" {
  name                  = "${var.tag_prefix}-container"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_redis_cache" "example" {
  name                      = "${var.tag_prefix}-redis"
  location                  = azurerm_resource_group.tfe.location
  resource_group_name       = azurerm_resource_group.tfe.name
  capacity                  = 1
  family                    = "P"
  sku_name                  = "Premium"
  enable_non_ssl_port       = true
  minimum_tls_version       = "1.2"
  private_static_ip_address = cidrhost(cidrsubnet(var.vnet_cidr, 8, 12), 22)
  subnet_id                 = azurerm_subnet.private2.id
  redis_version             = 6

  redis_configuration {
  }
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = var.tag_prefix
  location            = azurerm_resource_group.tfe.location
  resource_group_name = azurerm_resource_group.tfe.name
  dns_prefix          = var.tag_prefix

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.public1.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

